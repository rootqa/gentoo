# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils user versionator

DESCRIPTION="a man replacement that utilizes berkdb instead of flat files"
HOMEPAGE="http://www.nongnu.org/man-db/"
SRC_URI="mirror://nongnu/${PN}/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh sparc x86 ~amd64-linux ~arm-linux ~x86-linux"
IUSE="berkdb +gdbm +manpager nls selinux static-libs zlib"

CDEPEND=">=dev-libs/libpipeline-1.4.0
	berkdb? ( sys-libs/db:= )
	gdbm? ( sys-libs/gdbm )
	!berkdb? ( !gdbm? ( sys-libs/gdbm ) )
	sys-apps/groff
	zlib? ( sys-libs/zlib )
	!sys-apps/man"
DEPEND="${CDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig
	nls? (
		>=app-text/po4a-0.45
		sys-devel/gettext
	)"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-mandb )
"
PDEPEND="manpager? ( app-text/manpager )"

pkg_setup() {
	# Create user now as Makefile in src_install does setuid/chown
	enewgroup man 15
	enewuser man 13 -1 /usr/share/man man

	if (use gdbm && use berkdb) || (use !gdbm && use !berkdb) ; then #496150
		ewarn "Defaulting to USE=gdbm due to ambiguous berkdb/gdbm USE flag settings"
	fi
}

src_configure() {
	export ac_cv_lib_z_gzopen=$(usex zlib)
	econf \
		--docdir='$(datarootdir)'/doc/${PF} \
		--with-systemdtmpfilesdir="${EPREFIX}"/usr/lib/tmpfiles.d \
		--enable-setuid \
		--enable-cache-owner=man \
		--with-sections="1 1p 8 2 3 3p 4 5 6 7 9 0p tcl n l p o 1x 2x 3x 4x 5x 6x 7x 8x" \
		$(use_enable nls) \
		$(use_enable static-libs static) \
		--with-db=$(usex gdbm gdbm $(usex berkdb db gdbm))

	# Disable color output from groff so that the manpager can add it. #184604
	sed -i \
		-e '/^#DEFINE.*\<[nt]roff\>/{s:^#::;s:$: -c:}' \
		src/man_db.conf || die
}

src_install() {
	default
	dodoc docs/{HACKING,TODO}
	prune_libtool_files

	exeinto /etc/cron.daily
	newexe "${FILESDIR}"/man-db.cron man-db #289884
}

pkg_preinst() {
	local cachedir="${EROOT}var/cache/man"
	if [[ -f ${cachedir}/whatis ]] ; then
		einfo "Cleaning ${cachedir} from sys-apps/man"
		find "${cachedir}" -type f '!' '(' -name index.bt -o -name index.db ')' -delete
	fi
	if [[ -g ${cachedir} ]] ; then
		einfo "Resetting permissions on ${cachedir}"
		chown -R man:man "${cachedir}" || die
		find "${cachedir}" -type d -exec chmod g-s {} + || die
	elif [[ ! -d ${cachedir} ]] ; then
		mkdir -p "${cachedir}" || die
		chown man:man "${cachedir}" || die
	fi
}

pkg_postinst() {
	if [[ $(get_version_component_range 2 ${REPLACING_VERSIONS}) -lt 7 ]] ; then
		einfo "Rebuilding man-db from scratch with new database format!"
		mandb --quiet --create
	fi
}
