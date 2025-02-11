# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Network monitoring dockapp"
HOMEPAGE="http://www.dockapps.net/wmtime"
SRC_URI="https://dev.gentoo.org/~voyageur/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 ~mips ~ppc sparc ~x86"
IUSE=""

RDEPEND=">=x11-libs/libdockapp-0.7:=
	x11-libs/libX11
	x11-libs/libXpm"
DEPEND="${RDEPEND}"

DOCS=( BUGS CHANGES HINTS README TODO )
