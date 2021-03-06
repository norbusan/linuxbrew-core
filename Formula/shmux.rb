class Shmux < Formula
  desc "Execute the same command on many hosts in parallel"
  homepage "https://github.com/shmux/shmux"
  url "https://github.com/shmux/shmux/archive/v1.0.3.tar.gz"
  sha256 "c9f8863e2550e23e633cf5fc7a9c4c52d287059f424ef78aba6ecd98390fb9ab"

  bottle do
    cellar :any_skip_relocation
    sha256 "e433bd14622d3f77a35042649d0d73e888b164ab4f04431864fb68c9ec64b62c" => :mojave
    sha256 "bc38ad3a6feddd116edd9d3ab00ac18bc6663d08b9d111414975bdd1543d1b79" => :high_sierra
    sha256 "13f8831248e646784dd3cefd82707c45966ea05528e0c836156dea98b9c8c870" => :sierra
    sha256 "b9f5655875e42cc02cdc82f49a3aa29d2b9b3af7f5eff7f8c9dd8ffbe14262ed" => :x86_64_linux
  end

  uses_from_macos "ncurses"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/shmux", "-h"
  end
end
