# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils systemd udev

DESCRIPTION="DisplayLink USB Graphics Software"
HOMEPAGE="http://www.displaylink.com/downloads/ubuntu"
SRC_URI="http://www.displaylink.com/downloads/file?id=744 -> ${P}.zip"

LICENSE="DisplayLink"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="systemd"

QA_PREBUILT="/opt/displaylink/DisplayLinkManager"

DEPEND="app-admin/chrpath"
RDEPEND=">=sys-devel/gcc-4.8.3
	=x11-drivers/evdi-1.3*
	virtual/libusb:1
	|| ( x11-drivers/xf86-video-modesetting >=x11-base/xorg-server-1.17.0 )
	!systemd? ( sys-power/pm-utils )"

src_unpack() {
	default
	sh ./"${PN}"-"${PV}".run --noexec --target "${P}"
}

src_install() {
	if [[ ( $(gcc-major-version) -eq 5 && $(gcc-minor-version) -ge 1 ) || $(gcc-major-version) -gt 5 ]]; then
		MY_UBUNTU_VERSION=1604
	else
		MY_UBUNTU_VERSION=1404
	fi

	case "${ARCH}" in
		amd64)	MY_ARCH="x64" ;;
		*)		MY_ARCH="${ARCH}" ;;
	esac

	DLM="${S}/${MY_ARCH}-ubuntu-${MY_UBUNTU_VERSION}/DisplayLinkManager"

	dodir /opt/displaylink
	dodir /var/log/displaylink

	exeinto /opt/displaylink
	chrpath -d "${DLM}"
	doexe "${DLM}"

	insinto /opt/displaylink
	doins *.spkg

	udev_dorules "${FILESDIR}/99-displaylink.rules"

	insinto /opt/displaylink
	insopts -m0755
	newins "${FILESDIR}/udev.sh" udev.sh
	if use systemd; then
		newins "${FILESDIR}/pm-systemd-displaylink" suspend.sh
		dosym /opt/displaylink/suspend.sh /lib/systemd/system-sleep/displaylink.sh
		systemd_dounit "${FILESDIR}/dlm.service"
	else
		newins "${FILESDIR}/pm-displaylink" suspend.sh
		dosym /opt/displaylink/suspend.sh /etc/pm/sleep.d/displaylink.sh
		newinitd "${FILESDIR}/rc-displaylink-1.2" dlm
	fi
}

pkg_postinst() {
	einfo "The DisplayLinkManager Init is now called dlm"
	einfo "and is triggered by udev"
	einfo ""
	einfo "You should be able to use xrandr as follows:"
	einfo "xrandr --setprovideroutputsource 1 0"
	einfo "Repeat for more screens, like:"
	einfo "xrandr --setprovideroutputsource 2 0"
	einfo "Then, you can use xrandr or GUI tools like arandr to configure the screens, e.g."
	einfo "xrandr --output DVI-1-0 --auto"
}
