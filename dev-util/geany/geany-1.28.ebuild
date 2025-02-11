# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit eutils fdo-mime gnome2-utils

LANGS="ar ast be bg ca cs de el en_GB es et eu fa fi fr gl he hi hu id it ja kk ko lb lt mn nl nn pl pt pt_BR ro ru sk sl sr sv tr uk vi zh_CN ZH_TW"
NOSHORTLANGS="en_GB zh_CN zh_TW"

DESCRIPTION="GTK+ based fast and lightweight IDE"
HOMEPAGE="http://www.geany.org"
SRC_URI="http://download.geany.org/${P}.tar.bz2"

LICENSE="GPL-2+ HPND"
SLOT="0"
KEYWORDS="alpha amd64 arm ~ia64 ~ppc ~ppc64 sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="gtk3 +vte"

RDEPEND=">=dev-libs/glib-2.32:2
	!gtk3? (
		>=x11-libs/gtk+-2.24:2
		vte? ( x11-libs/vte:0 )
	)
	gtk3? (
		>=x11-libs/gtk+-3.0:3
		vte? ( x11-libs/vte:2.90 )
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	dev-util/intltool
	sys-devel/gettext"

pkg_setup() {
	strip-linguas ${LANGS}
}

src_prepare() {
	default

	# Syntax highlighting for Portage
	sed -i -e "s:*.sh;:*.sh;*.ebuild;*.eclass;:" \
		data/filetype_extensions.conf || die
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		$(use_enable gtk3) \
		$(use_enable vte)
}

src_install() {
	emake DESTDIR="${D}" DOCDIR="${ED}/usr/share/doc/${PF}" install
	rm -f "${ED}"/usr/share/doc/${PF}/{COPYING,GPL-2,ScintillaLicense.txt}
	prune_libtool_files --all
}

pkg_preinst() { gnome2_icon_savelist; }

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
