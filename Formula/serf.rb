class Serf < Formula
  desc "Service orchestration and management tool"
  homepage "https://serfdom.io/"
  url "https://github.com/hashicorp/serf.git",
      :tag      => "v0.8.3",
      :revision => "15cfd05de3dffb3664aa37b06e91f970b825e380"
  head "https://github.com/hashicorp/serf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "692266b0fa6ba7a7772849938ba42dc9246d1f117a216bdcb8bd1a130181a814" => :mojave
    sha256 "979604efa2ecf8c34e88d7060c84ffb003fe9eeafd26871bbc3cc94a77e0eede" => :high_sierra
    sha256 "e6578320d01e78c038df703f072ef26b9a340ce00146cd96ae1b9585331fa48b" => :sierra
    sha256 "3d76f4f20d7551eaf3aa0c1bad76d62f9e25bcc33015342b7a172e6a1c7cbeff" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "govendor" => :build
  depends_on "gox" => :build
  depends_on "zip" => :build unless OS.mac?

  def install
    contents = Dir["*"]
    gopath = buildpath/"gopath"
    (gopath/"src/github.com/hashicorp/serf").install contents

    ENV["GOPATH"] = gopath
    ENV["XC_OS"] = OS.mac? ? "darwin" : "linux"
    ENV["XC_ARCH"] = "amd64"

    (gopath/"bin").mkpath

    cd gopath/"src/github.com/hashicorp/serf" do
      system "make", "bin"
      bin.install "bin/serf"
      prefix.install_metafiles
    end
  end

  test do
    begin
      pid = fork do
        exec "#{bin}/serf", "agent"
      end
      sleep 1
      assert_match /:7946.*alive$/, shell_output("#{bin}/serf members")
    ensure
      system "#{bin}/serf", "leave"
      Process.kill "SIGINT", pid
      Process.wait pid
    end
  end
end
