#!/bin/bash

source debian/vars.sh

set -x

# install module
install -d $DEB_INSTALL_ROOT$_httpd_moddir
install apache2/.libs/$module_name.so $DEB_INSTALL_ROOT$_httpd_moddir/$module_name.so
# install loadmodule configuration
mkdir -p $DEB_INSTALL_ROOT$_httpd_modconfdir
install $SOURCE2 $DEB_INSTALL_ROOT$_httpd_modconfdir/800-$module_name.conf
# install modsecurity configuration
mkdir -p $DEB_INSTALL_ROOT$_httpd_confdir
mkdir -p $DEB_INSTALL_ROOT$_httpd_confdir/modsec
install $SOURCE1.new $DEB_INSTALL_ROOT$_httpd_confdir/modsec2.conf
install $SOURCE3.new $DEB_INSTALL_ROOT$_httpd_confdir/modsec/modsec2.user.conf
install $SOURCE4.new $DEB_INSTALL_ROOT$_httpd_confdir/modsec/modsec2.cpanel.conf
mkdir -p $DEB_INSTALL_ROOT/$_localstatedir/log/modsec_audit
# mlogc
install -d $DEB_INSTALL_ROOT$_localstatedir/log/mlogc
install -d $DEB_INSTALL_ROOT$_localstatedir/log/mlogc/data
install -d $DEB_INSTALL_ROOT$_bindir
install -m0755 mlogc/mlogc $DEB_INSTALL_ROOT$_bindir/mlogc
install -m0755 mlogc/mlogc-batch-load.pl $DEB_INSTALL_ROOT$_bindir/mlogc-batch-load
install -m0644 mlogc/mlogc-default.conf $DEB_INSTALL_ROOT$_sysconfdir/mlogc.conf
mkdir -p $DEB_INSTALL_ROOT/etc/cpanel/ea4
echo -n $version > $DEB_INSTALL_ROOT/etc/cpanel/ea4/modsecurity.version

mkdir -p debian/tmp/etc/apache2/conf.d/modsec
mkdir -p debian/tmp/etc/apache2/conf.modules.d
mkdir -p debian/tmp/etc/apache2/logs/modsec_audit
mkdir -p debian/tmp/opt/cpanel/root/usr/bin
mkdir -p debian/tmp/usr/bin
mkdir -p debian/tmp/etc/apache2/conf.d
mkdir -p debian/tmp/usr/lib64/apache2/modules

cp debian/tmp/opt/cpanel/root/etc/apache2/conf.d/modsec/modsec2.cpanel.conf     debian/tmp/etc/apache2/conf.d/modsec/modsec2.cpanel.conf
cp debian/tmp/opt/cpanel/root/etc/apache2/conf.d/modsec/modsec2.user.conf       debian/tmp/etc/apache2/conf.d/modsec/modsec2.user.conf
cp debian/tmp/opt/cpanel/root/etc/apache2/conf.d/modsec2.conf                   debian/tmp/etc/apache2/conf.d/modsec/modsec2.conf
cp debian/tmp/opt/cpanel/root/etc/apache2/conf.d/modsec2.conf                   debian/tmp/etc/apache2/conf.d/modsec2.conf
cp debian/tmp/opt/cpanel/root/etc/apache2/conf.modules.d/800-mod_security2.conf debian/tmp/etc/apache2/conf.modules.d/800-mod_security2.conf
cp debian/tmp/opt/cpanel/root/usr/lib64/apache2/modules/mod_security2.so        debian/tmp/usr/lib64/apache2/modules/mod_security2.so
cp debian/tmp/opt/cpanel/root/usr/bin/mlogc                                     debian/tmp/usr/bin/mlogc
cp debian/tmp/opt/cpanel/root/etc/mlogc.conf                                    debian/tmp/etc/mlogc.conf 
cp debian/tmp/opt/cpanel/root/usr/bin/mlogc-batch-load                          debian/tmp/usr/bin/mlogc-batch-load

echo "FILELIST"
find . -type f -print | sort

