class Mpfr < Formula
  desc "C library for multiple-precision floating-point computations"
  homepage "http://www.mpfr.org/"
  # Upstream is down a lot, so use mirrors
  url "https://mirrors.ocf.berkeley.edu/debian/pool/main/m/mpfr4/mpfr4_3.1.4.orig.tar.xz"
  mirror "https://ftp.gnu.org/gnu/mpfr/mpfr-3.1.4.tar.xz"
  sha256 "761413b16d749c53e2bfd2b1dfaa3b027b0e793e404b90b5fbaeef60af6517f5"

  bottle do
    cellar :any
    sha256 "06b1521d06eeec85bf2052fd416f19f7624901641596617e39b8c433540d990f" => :el_capitan
    sha256 "2695bf9b6090c817144b0650a9eb332fdc22efa37265fefd7ea2c55d4f62732b" => :yosemite
    sha256 "47dc6d25a9ba43dd2e710849d7d2dbfffc6de3ded02554ea973cd26797a2b31d" => :mavericks
    sha256 "11df9a2ced120b21852181271ba252febab1c613ee0b4c9c8b43123364c099c6" => :x86_64_linux
  end

  # http://www.mpfr.org/mpfr-current/allpatches
  patch do
    url "https://raw.githubusercontent.com/Homebrew/patches/30141937f9d16/mpfr/3.1.4-patches.diff"
    sha256 "9a03c3f304feaff747d1832f4a0f3653bbd24764df403305add0b76ca6cd6541"
  end

  option "32-bit"

  depends_on "gmp"

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/Homebrew/homebrew/issues/15061
    EOS
  end

  def install
    ENV.m32 if build.build_32_bit?

    # Fix error makeinfo: command not found
    # The mpfr.info timestamp is older than the mpfr.texi timestamp.
    touch "doc/mpfr.info"

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}",
                          "--disable-silent-rules"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gmp.h>
      #include <mpfr.h>

      int main()
      {
        mpfr_t x;
        mpfr_init(x);
        mpfr_clear(x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-lgmp", "-lmpfr", "-o", "test"
    system "./test"
  end
end
