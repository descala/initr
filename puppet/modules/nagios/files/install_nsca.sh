#!/bin/bash
##################
# puppet managed #
##################

cd /usr/local/src

if [ ! -f master.zip ]; then
  wget https://github.com/NagiosEnterprises/nsca/archive/master.zip
fi
if [ ! -d nsca-master ]; then
  yum install -y unzip # meehhh
  unzip master.zip
fi

cd nsca-master
./configure
make all
mkdir -p /usr/local/nsca
mkdir -p /usr/local/nsca/etc
mkdir -p /usr/local/nsca/bin

# CLIENT
cp src/send_nsca /usr/local/nsca/bin/
cp sample-config/send_nsca.cfg /usr/local/nsca/etc/
chmod 640 /usr/local/nsca/etc/send_nsca.cfg
