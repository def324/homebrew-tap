class Megawren < Formula
  desc "Terminal file browser and transfer client for MEGA"
  homepage "https://github.com/def324/megawren"
  url "https://github.com/def324/megawren/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "fe5b8fdac96ad2f48e5ffc6cf4460d5826e0970ad9b9747d42c1bbcd7154bb5b"
  license "MIT"

  bottle do
    root_url "https://github.com/def324/homebrew-tap/releases/download/megawren-0.3.0"
    sha256 cellar: :any, arm64_tahoe:   "dfa1200575d5b5598e9c6a9ce621da9533d5a17bcc4d76afd3188a3983d0cea5"
    sha256 cellar: :any, arm64_sequoia: "2e04cb272f9696f80d8fe0b84ff4fa5ce1226ef069acf4304921bf09999380b2"
    sha256 cellar: :any, arm64_linux:   "d19e81cf21c47043dec47fa769b10401b98ba4f6b48e98bf3767b99f65bd1970"
    sha256 cellar: :any, x86_64_linux:  "062a0cca920348cb47e0b33bdd6757ebb3956f9863475e51483f8e5c8689292e"
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
