class StressNg < Formula
  desc "Stress test a computer system in various selectable ways"
  homepage "https://kernel.ubuntu.com/~cking/stress-ng/"
  url "https://kernel.ubuntu.com/~cking/tarballs/stress-ng/stress-ng-0.10.01.tar.xz"
  sha256 "4a74f2a60b248dc7ff20e950facb4a7d010f46bf8c0cfcbed6fecf7c4daa8f3d"

  bottle do
    cellar :any_skip_relocation
    sha256 "868d44fc214c55f6d8b08bd46549622af7e3fb894c6b5c69db10609f2b80a8b4" => :mojave
    sha256 "2761be83935dc3df6c8732ec4e06c36b13a702920816d51cc1aea9b879ae9260" => :high_sierra
    sha256 "cd8f7598b445aaac18f4aa9e15579ffc76105ab5f611660afa730077feea1d87" => :sierra
    sha256 "13c78801d10e995889f78276ecdc66cb66a2f69052e9c0245d9d46db727e7645" => :x86_64_linux
  end

  depends_on :macos => :sierra if OS.mac?
  uses_from_macos "zlib"

  def install
    inreplace "Makefile", "/usr", prefix
    system "make"
    system "make", "install"
  end

  test do
    output = shell_output("#{bin}/stress-ng -c 1 -t 1 2>&1")
    assert_match "successful run completed", output
  end
end
