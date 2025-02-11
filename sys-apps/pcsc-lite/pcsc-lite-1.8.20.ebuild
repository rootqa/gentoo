# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
PYTHON_COMPAT=( python2_7 )

inherit eutils python-single-r1 systemd udev user multilib-minimal

DESCRIPTION="PC/SC Architecture smartcard middleware library"
HOMEPAGE="http://pcsclite.alioth.debian.org/"

STUPID_NUM="4203"
MY_P="${PN}-${PV/_/-}"
SRC_URI="http://alioth.debian.org/download.php/file/${STUPID_NUM}/${MY_P}.tar.bz2"
S="${WORKDIR}/${MY_P}"

# GPL-2 is there for the init script; everything else comes from
# upstream.
LICENSE="BSD ISC MIT GPL-3+ GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ~ia64 ~m68k ~ppc ~ppc64 ~s390 ~sh sparc x86 ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"

# This is called libusb so that it doesn't fool people in thinking that
# it is _required_ for USB support. Otherwise they'll disable udev and
# that's going to be worse.
IUSE="python libusb policykit selinux +udev"

REQUIRED_USE="^^ ( udev libusb ) \
	python? ( ${PYTHON_REQUIRED_USE} )"

# No dependencies need the MULTILIB_DEPS because the libraries are actually
# standalone, the deps are only needed for the daemon itself.
CDEPEND="libusb? ( virtual/libusb:1 )
	udev? ( virtual/udev )
	policykit? ( >=sys-auth/polkit-0.111 )
	python? ( ${PYTHON_DEPS} )"
DEPEND="${CDEPEND}
	virtual/pkgconfig"
RDEPEND="${CDEPEND}
	!<app-crypt/ccid-1.4.1-r1
	!<sys-apps/baselayout-2
	!<sys-apps/openrc-0.11.8
	selinux? ( sec-policy/selinux-pcscd )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.8.11-polkit-pcscd.patch
)

DOCS=( AUTHORS DRIVERS HELP README SECURITY ChangeLog )

pkg_setup() {
	use python && python-single-r1_pkg_setup
	enewgroup openct # make sure it exists
	enewgroup pcscd
	enewuser pcscd -1 -1 /run/pcscd pcscd,openct
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-maintainer-mode \
		--enable-usbdropdir="${EPREFIX}/usr/$(get_libdir)/readers/usb" \
		--enable-ipcdir=/run/pcscd \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)" \
		$(multilib_native_use_enable udev libudev) \
		$(multilib_native_use_enable libusb) \
		$(multilib_native_use_enable policykit polkit)
}

multilib_src_install_all() {
	einstalldocs

	newinitd "${FILESDIR}"/pcscd-init.7 pcscd

	if use udev; then
		insinto "$(get_udevdir)"/rules.d
		doins "${FILESDIR}"/99-pcscd-hotplug.rules
	fi

	for f in "${ED}/usr/bin/pcsc-spy"; do
		if use python; then
			python_fix_shebang "${f}"
		else
			rm "${f}"
		fi
	done
}

pkg_postinst() {
	elog "Starting from version 1.6.5, pcsc-lite will start as user nobody in"
	elog "the pcscd group, to avoid running as root."
	elog ""
	elog "This also means you need the newest drivers available so that the"
	elog "devices get the proper owner."
	elog ""
	elog "Furthermore, a conf.d file is no longer installed by default, as"
	elog "the default configuration does not require one. If you need to"
	elog "pass further options to pcscd, create a file and set the"
	elog "EXTRA_OPTS variable."
	elog ""
	if use udev; then
		elog "Hotplug support is provided by udev rules; you only need to tell"
		elog "the init system to hotplug it, by setting this variable in"
		elog "/etc/rc.conf:"
		elog ""
		elog "    rc_hotplug=\"pcscd\""
	fi
}
