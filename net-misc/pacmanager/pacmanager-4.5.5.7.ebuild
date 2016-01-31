# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib
DESCRIPTION="PAC is a Perl/GTK replacement for SecureCRT/Putty/etc"
HOMEPAGE="http://sites.google.com/site/davidtv"
SRC_URI="mirror://sourceforge/${PN}/pac-4.0/pac-${PV}-all.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="freerdp mosh rdesktop webdav vnc"

RDEPEND="freerdp? ( net-misc/freerdp )
    mosh? ( net-misc/mosh )
	rdesktop? ( net-misc/rdesktop )
	webdav? ( net-misc/cadaver )
	vnc? ( || ( net-misc/tigervnc net-misc/tightvnc ) )
	dev-libs/ossp-uuid[perl]
	dev-perl/crypt-cbc
	dev-perl/gtk2-perl
    dev-perl/Socket6
    dev-perl/Net-ARP
	dev-perl/Crypt-Rijndael
	dev-perl/Crypt-Blowfish
	dev-perl/Gtk2-Ex-Simple-List
	dev-perl/Gtk2-Unique
	dev-perl/gnome2-perl
	dev-perl/gnome2-gconf
	dev-perl/gtk2-gladexml
	dev-perl/Gnome2-Vte
	dev-perl/Expect
	dev-perl/IO-Stty"

src_prepare() {
    rm -rf pac/lib/ex/vte*
    find pac/utils pac/lib pac/pac -type f | while read f
    do
        sed -i -e "s@\$RealBin[^']*\('\?\)\([./]*\)/lib@\1/usr/$(get_libdir)/pacmanager@g" "$f"
        sed -i -e "s@\$RealBin[^']*\('\?\)\([./]*\)/res@\1/usr/share/pacmanager@g" "$f"
    done
}

src_install() {
    dobin pac/pac
    dodoc pac/README

    doman pac/res/pac.1
    insinto /usr/share/applications
    doins pac/res/pac.desktop
    rm pac/res/{pac.1,pac.desktop}

    insinto /usr/share/pixmaps
    newins pac/res/pac64x64.png pac.png

    insinto /usr/$(get_libdir)/${PN}
    doins -r pac/lib/*
    insinto /usr/share/${PN}
    doins -r pac/res/*
    doins -r pac/utils
    doins pac/qrcode_pacmanager.png
}

pkg_postinst()
{
    einfo "Please install keepassx if you need a password manager."
}