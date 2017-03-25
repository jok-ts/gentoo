# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit flag-o-matic autotools

DESCRIPTION="GNU Ubiquitous Intelligent Language for Extensions"
HOMEPAGE="https://www.gnu.org/software/guile/"
SRC_URI="mirror://gnu/guile/${P}.tar.gz"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
LICENSE="LGPL-3+"
IUSE="debug debug-malloc +deprecated +networking +nls +regex +threads" # upstream recommended +networking +nls

# emacs useflag removal not working

RDEPEND="
	app-eselect/eselect-guile
	>=dev-libs/boehm-gc-7.0[threads?]
	dev-libs/gmp:=
	virtual/libffi
	dev-libs/libltdl:=
	dev-libs/libunistring:0=
	sys-devel/libtool
	sys-libs/ncurses:0=
	sys-libs/readline:0="
DEPEND="${RDEPEND}
	virtual/pkgconfig
	sys-apps/texinfo
	sys-devel/gettext"

SLOT="2/22" # subslot is soname version
MAJOR="2.0"

DOCS=( GUILE-VERSION HACKING README )

PATCHES=( "${FILESDIR}/${PN}-2-snarf.patch" )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# see bug #178499
	filter-flags -ftree-vectorize

	econf \
		--program-suffix="-${MAJOR}" \
		--infodir="${EPREFIX}"/usr/share/info/guile-${MAJOR} \
		--disable-error-on-warning \
		--disable-rpath \
		--enable-posix \
		--disable-static \
		--without-libgmp-prefix \
		--without-libiconv-prefix \
		--without-libintl-prefix \
		--without-libltdl-prefix \
		--without-libreadline-prefix \
		--without-libunistring-prefix \
		$(use_enable debug guile-debug) \
		$(use_enable debug-malloc) \
		$(use_enable deprecated) \
		$(use_enable networking) \
		$(use_enable nls) \
		$(use_enable regex) \
		$(use_with threads)
}

src_install() {
	default

	# Maybe there is a proper way to do this? Symlink handled by eselect
	mv "${ED}"/usr/share/aclocal/guile.m4 "${ED}"/usr/share/aclocal/guile-${MAJOR}.m4 || die "rename of guile.m4 failed"

	# From Novell
	# 	https://bugzilla.novell.com/show_bug.cgi?id=874028#c0
	dodir /usr/share/gdb/auto-load/$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/libguile-*-gdb.scm "${ED}"/usr/share/gdb/auto-load/$(get_libdir) || die

	# necessary for registering slib, see bug 206896
	keepdir /usr/share/guile/site

	# Dark magic necessary for some deps
	# dosym libguile-2.0.so /usr/$(get_libdir)/libguile.so
}

pkg_postinst() {
	eselect guile update --if-unset
}
