#!/bin/bash

source debian/vars.sh

# install modsec config (cPanel & WHM expects this name.. don't change it)
set -e "s|@HTTPD_LOGDIR@|$_httpd_logdir|" \
    -e "s|@HTTPD_CONFDIR@|$_httpd_confdir|" \
    $SOURCE1 > $SOURCE1.new
sed -e "s|@HTTPD_LOGDIR@|$_httpd_logdir|" \
    -e "s|@HTTPD_CONFDIR@|$_httpd_confdir|" \
    $SOURCE3 > $SOURCE3.new
sed -e "s|@HTTPD_LOGDIR@|$_httpd_logdir|" \
    -e "s|@HTTPD_CONFDIR@|$_httpd_confdir|" \
    $SOURCE4 > $SOURCE4.new
./configure  \
    --enable-pcre-match-limit-recursion=1000000 \
    --with-apr=$ea_apr_dir --with-apu=$ea_apu_dir \
    --with-apxs=$_httpd_apxs \
    --with-curl=/usr/bin/curl-config \
    --with-libxml
make
