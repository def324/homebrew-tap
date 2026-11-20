class Megawren < Formula
  desc "Terminal file browser and transfer client for MEGA"
  homepage "https://github.com/def324/megawren"
  url "https://github.com/def324/megawren/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "7636194d6d5f2d2a3bbff15f3f4d58cd21803b44731d0643c41f3a6d4cdc0179"
  license "MIT"

  bottle do
    root_url "https://github.com/def324/homebrew-tap/releases/download/megawren-0.2.0"
    sha256 cellar: :any, arm64_tahoe:   "deb3498805f4d746cd1097df5cb696c73b92ef8f1a6d7ed0fa69e4d47e7aae9e"
    sha256 cellar: :any, arm64_sequoia: "8e0691cf0543193c3de1c0b858dd58f34804ab2acb5e0e62249ac0a7d889053a"
    sha256 cellar: :any, x86_64_linux:  "591dfc7a0a3d4c52903d880044c8e4f974f02603f2bb88aff2c92caf4fbc54df"
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
