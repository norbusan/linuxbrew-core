class Flex < Formula
  desc "Fast Lexical Analyzer, generates Scanners (tokenizers)"
  homepage "https://github.com/westes/flex"
  url "https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
  sha256 "e87aae032bf07c26f85ac0ed3250998c37621d95f8bd748b31f15b33c45ee995"
  revision 1

  bottle do
    sha256 "2051ed8f0de322732b111f2cc82069e82f6dfd4d839e6d098bbebcd7f92220e6" => :mojave
    sha256 "9c224c27a3d40a53b6f778a6b825f8b4f14654080b144e50f1bec9cc608c757d" => :high_sierra
    sha256 "a958106ee0895b21c7577478b847ecdbc601ce6a723543c5da455bfe0eee5f8f" => :sierra
    sha256 "d96d0062e78529ae5a0ff049eeaf1216df4a5e47f2fbda680473b48b15f59d1a" => :x86_64_linux
  end

  head do
    url "https://github.com/westes/flex.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build

    # https://github.com/westes/flex/issues/294
    depends_on "gnu-sed" => :build

    depends_on "libtool" => :build
  end

  keg_only :provided_by_macos, "some formulae require a newer version of flex"

  depends_on "help2man" => :build
  depends_on "gettext"
  unless OS.mac?
    depends_on "m4"
    depends_on "bison" => :build
  end

  def install
    if build.head?
      ENV.prepend_path "PATH", Formula["gnu-sed"].opt_libexec/"gnubin"

      system "./autogen.sh"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--enable-shared",
                          "--prefix=#{prefix}"
    system "make", "install"
    bin.install_symlink "flex" => "lex" unless OS.mac?
  end

  test do
    (testpath/"test.flex").write <<~EOS
      CHAR   [a-z][A-Z]
      %%
      {CHAR}+      printf("%s", yytext);
      [ \\t\\n]+   printf("\\n");
      %%
      int main()
      {
        yyin = stdin;
        yylex();
      }
    EOS
    system "#{bin}/flex", "test.flex"
    system ENV.cc, "lex.yy.c", "-L#{lib}", "-lfl", "-o", "test"
    assert_equal shell_output("echo \"Hello World\" | ./test"), <<~EOS
      Hello
      World
    EOS
  end
end
