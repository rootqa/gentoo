# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools

DESCRIPTION="Copy data from standard input to X clipboard"
HOMEPAGE="https://github.com/astrand/xclip"
SRC_URI="https://github.com/astrand/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm ~hppa ~ia64 ppc ppc64 sparc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXmu"
DEPEND="${RDEPEND}
	x11-libs/libXt"

src_prepare() {
	default
	eautoreconf
}
