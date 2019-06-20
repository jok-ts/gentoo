# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="QR decoder library"
HOMEPAGE="https://github.com/dlbeer/quirc"

MY_GIT_COMMIT="5d71b1853e7604280b7c75785fd8749da68c8e70"
SRC_URI="https://github.com/dlbeer/${PN}/archive/${MY_GIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"

KEYWORDS="~amd64"

#IUSE=""

RDEPEND="media-libs/sdl-gfx"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${MY_GIT_COMMIT}"

src_prepare() {
	default
	sed -e "s:\$(PREFIX)/lib:${EPREFIX}/usr/$(get_libdir):g" \
		-e "s:\$(PREFIX):${EPREFIX}/usr:g" \
		-e "/-shared -o/s: -o : -Wl,-soname,libquirc.so.1 -o :" \
		-i ${S}/Makefile
	append-flags -fPIC
}

src_install() {
	# the makefile expects the target directories to exist
	#install -d -o root -g root -m 0755 \
	#		${D}/"${EPREFIX}"/{usr/{include,$(get_libdir),bin}}
	#emake DESTDIR="${D}" install

	dobin quirc-demo quirc-scanner
	dolib.so libquirc.so.1.0
	dosym libquirc.so.1.0 /usr/$(get_libdir)/libquirc.so.1

	insinto /usr/include/
	doins lib/quirc.h
}
