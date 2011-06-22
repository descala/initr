#!/bin/bash
##################
# puppet managed #
##################

cd /usr/local/src

if [ ! -f nsca-2.7.2.tar.gz ]; then
  wget http://heanet.dl.sourceforge.net/sourceforge/nagios/nsca-2.7.2.tar.gz
fi
if [ ! -d nsca-2.7.2 ]; then
  tar xvzf nsca-2.7.2.tar.gz
fi

cd nsca-2.7.2
./configure
make all
mkdir /usr/local/nsca
mkdir /usr/local/nsca/etc
mkdir /usr/local/nsca/bin

# CLIENT
cp src/send_nsca /usr/local/nsca/bin/
cp sample-config/send_nsca.cfg /usr/local/nsca/etc/
chmod 640 /usr/local/nsca/etc/send_nsca.cfg


