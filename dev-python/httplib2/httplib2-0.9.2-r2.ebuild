# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5} pypy pypy3 )

inherit distutils-r1

DESCRIPTION="A comprehensive HTTP client library"
HOMEPAGE="https://pypi.python.org/pypi/httplib2 https://github.com/jcgregorio/httplib2"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 ~ia64 ~ppc ~ppc64 sparc x86 ~amd64-linux ~x86-linux ~x64-macos"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

# tests connect to random remote sites
RESTRICT="test"

PATCHES=(
	"${FILESDIR}/python-httplib2-0.9-cve-2013-2037.patch"
)

python_prepare_all() {
	chmod o+r */*egg*/* || die
	distutils-r1_python_prepare_all
}

python_test() {
	if [[ ${EPYTHON} == python2.7 ]] ; then
		cd python2 || die
	else
		cd python3 || die
	fi

	"${PYTHON}" httplib2test.py || die
}
