# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="ssl?,xml"

inherit distutils-r1

MY_PN="SOAPpy"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="SOAP Services for Python"
HOMEPAGE="http://pywebsvcs.sourceforge.net/ https://pypi.python.org/pypi/SOAPpy"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh sparc x86"

IUSE="examples ssl"

RDEPEND="dev-python/wstools[${PYTHON_USEDEP}]
	dev-python/defusedxml[${PYTHON_USEDEP}]
	ssl? ( dev-python/m2crypto[${PYTHON_USEDEP}] )"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"

S="${WORKDIR}/${MY_P}"

DOCS=( CHANGES.txt README.txt docs/. )

python_install_all() {
	if use examples; then
		docinto examples
		dodoc -r bid contrib tools validate
		docompress -x /usr/share/doc/${PF}/examples
	fi

	distutils-r1_python_install_all
}
