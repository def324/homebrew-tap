class Megawren < Formula
  desc "Terminal file browser and transfer client for MEGA"
  homepage "https://github.com/def324/megawren"
  url "https://github.com/def324/megawren/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "fe5b8fdac96ad2f48e5ffc6cf4460d5826e0970ad9b9747d42c1bbcd7154bb5b"
  license "MIT"

  bottle do
    root_url "https://github.com/def324/homebrew-tap/releases/download/megawren-0.4.0"
    sha256 cellar: :any, arm64_tahoe:   "ddce23a37b25b253f4c7ecde1ae74f26f131f34cb4c8418de254fb2399edaae0"
    sha256 cellar: :any, arm64_sequoia: "4ec521f93cfa129b3e26d2c9a9cf4b7415d9342d836197bfde59f00b5890169f"
    sha256 cellar: :any, arm64_linux:   "600e44815b88ee31459eaf48fa9f97f62a021a126c33c45625328720e47d11f9"
    sha256 cellar: :any, x86_64_linux:  "a1a57093ca86b827263d8e025ab7a426135c2dcc056aa4627cbaae3ed2f5d384"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "cryptopp"
  depends_on "icu4c@79"
  depends_on "libsodium"
  depends_on "zstd"

  uses_from_macos "python" => :build
  uses_from_macos "curl"
  uses_from_macos "sqlite"

  on_macos do
    depends_on macos: :sequoia
  end

  on_linux do
    depends_on "openssl@3"
  end

  # The official SDK is a pinned upstream submodule without a standalone core formula.
  resource "mega-sdk" do
    url "https://github.com/meganz/sdk/archive/2c95a487b4b297dba1d792c88189d432c3452694.tar.gz"
    version "10.22.0"
    sha256 "8e60483578557f2a3e8132409a2e4111110534d7d98db8884015878dbe4b9556"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    sdk = buildpath/"vendor/mega"
    resource("mega-sdk").stage sdk
    ENV["MEGAWREN_SDK_SOURCE"] = sdk
    ENV["CRYPTOPP_PREFIX"] = formula_opt_prefix("cryptopp")
    ENV.prepend_path "CMAKE_PREFIX_PATH", formula_opt_prefix("icu4c@79")
    ENV["BUILD_JOBS"] = ENV.make_jobs.to_s
    ENV["ZSTD_SYS_USE_PKG_CONFIG"] = "1"
    system "./scripts/build-sdk.sh", "-DCMAKE_INSTALL_PREFIX=#{libexec}", "-DCMAKE_INSTALL_LIBDIR=lib",
                                    "-DCMAKE_INSTALL_INCLUDEDIR=#{sdk}/include"
    (libexec/"lib").install Dir["target/sdk/lib/libSDKlib*"]
    system "./scripts/cargo.sh", "build", "--release", "--locked", "--offline"
    bin.install "target/release/megawren"
    pkgshare.install "THIRD_PARTY_NOTICES.md"
    system "python3", "scripts/package.py", "--licenses-only", pkgshare/"licenses"
  end

  test do
    output = shell_output("#{bin}/megawren status")
    assert_match "#{testpath}/.megawren/session.enc (none)", output
    refute_path_exists testpath/".megawren"
    assert_match "No saved login", shell_output("#{bin}/megawren --unlock-stdin ls --json </dev/null 2>&1", 1)
  end
end
