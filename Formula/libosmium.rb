class Libosmium < Formula
  desc "Fast and flexible C++ library for working with OpenStreetMap data"
  homepage "https://osmcode.org/libosmium/"
  url "https://github.com/osmcode/libosmium/archive/v2.15.2.tar.gz"
  sha256 "be53024e16946ce49ff787f3ce569aa5710010236db68f971433ac6a10318a46"

  bottle do
    cellar :any_skip_relocation
    sha256 "75e519364edc883bffa07dfef3d88df6d4fe56bcf0cc19c0951fcf9fa95fd57e" => :mojave
    sha256 "75e519364edc883bffa07dfef3d88df6d4fe56bcf0cc19c0951fcf9fa95fd57e" => :high_sierra
    sha256 "765b186c188877807aa06e03d97084f990e3b1cb83d25309a711d57c0042ac49" => :sierra
    sha256 "8ee56708cbfeae370d19e951c76bd5606428f1bd2af7f9721899ea79732cd9eb" => :x86_64_linux
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  uses_from_macos "expat"

  resource "protozero" do
    url "https://github.com/mapbox/protozero/archive/v1.6.8.tar.gz"
    sha256 "019a0f3789ad29d7e717cf2e0a7475b36dc180508867fb47e8c519885b431706"
  end

  def install
    resource("protozero").stage { libexec.install "include" }
    system "cmake", ".", "-DINSTALL_GDALCPP=ON",
                         "-DINSTALL_UTFCPP=ON",
                         "-DPROTOZERO_INCLUDE_DIR=#{libexec}/include",
                         *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.osm").write <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <osm version="0.6" generator="handwritten">
        <node id="1" lat="0.001" lon="0.001" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z"></node>
        <node id="2" lat="0.002" lon="0.002" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z"></node>
        <way id="1" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z">
          <nd ref="1"/>
          <nd ref="2"/>
          <tag k="name" v="line"/>
        </way>
        <relation id="1" user="Dummy User" uid="1" version="1" changeset="1" timestamp="2015-11-01T19:00:00Z">
          <member type="node" ref="1" role=""/>
          <member type="way" ref="1" role=""/>
        </relation>
      </osm>
    EOS

    (testpath/"test.cpp").write <<~EOS
      #include <cstdlib>
      #include <iostream>
      #include <osmium/io/xml_input.hpp>

      int main(int argc, char* argv[]) {
        osmium::io::File input_file{argv[1]};
        osmium::io::Reader reader{input_file};
        while (osmium::memory::Buffer buffer = reader.read()) {}
        reader.close();
      }
    EOS

    system ENV.cxx, "-std=c++11", *("-stdlib=libc++" if OS.mac?), "-o", "libosmium_read", "test.cpp", "-lexpat", *("-pthread" unless OS.mac?)
    system "./libosmium_read", "test.osm"
  end
end
