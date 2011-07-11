#!/bin/bash
##########################
#     Puppet managed     #
##########################
#
# download and install dspam from sources.
#

cd /tmp


# wget http://dspam.nuclearelephant.com/sources/dspam-3.8.0.tar.gz
# Descarreguem d'ingent, on esta aplicat el patch de http://mail-index.netbsd.org/pkgsrc-users/2008/08/30/msg007953.html
wget http://www.ingent.net/dspam-3.8.0.tar.gz

tar xvzf dspam-3.8.0.tar.gz
cd dspam-3.8.0
./configure --enable-daemon --enable-clamav --enable-domain-scale --with-dspam-owner=root --with-dspam-group=dspam
make
make install

#TODO: comprovar si ha compilat ok

# webui
mkdir /var/www/html/dspam
cp -r webui/htdocs/* /var/www/html/dspam/
cp -r webui/cgi-bin/* /var/www/html/dspam/

adduser dspam -d /usr/local/var/dspam/
chown -R dspam:dspam /var/www/html/dspam
chown -R dspam:dspam /usr/local/var/dspam/
