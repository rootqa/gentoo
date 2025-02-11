# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils

DESCRIPTION="A realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3"
HOMEPAGE="http://mpg321.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P/-/_}.orig.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ~ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="alsa ipv6"

RDEPEND="app-eselect/eselect-mpg123
	>=media-libs/libao-1
	media-libs/libid3tag
	media-libs/libmad
	sys-libs/zlib
	alsa? ( media-libs/alsa-lib )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${P}-orig

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.2.12-check-for-lround.patch \
		"${FILESDIR}"/${P}-format-security.patch
	eautoreconf
}

src_configure() {
	econf \
		--disable-mpg123-symlink \
		$(use_enable ipv6) \
		$(use_enable alsa)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS BUGS HACKING README* THANKS TODO # NEWS and ChangeLog are dead
	mv "${ED}"/usr/bin/mpg321{,-mpg123}
}

pkg_postinst() {
	eselect mpg123 update ifunset
}

pkg_postrm() {
	eselect mpg123 update ifunset
}
