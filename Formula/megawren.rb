class Megawren < Formula
  desc "Terminal file browser and transfer client for MEGA"
  homepage "https://github.com/def324/megawren"
  url "https://github.com/def324/megawren/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7d4b659427c47a4c9924dd2171341e6f327bcb043dcd33e393df546a2810ba5d"
  license "MIT"

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
