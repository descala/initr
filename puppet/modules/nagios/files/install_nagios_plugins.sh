#!/bin/bash
##################
# puppet managed #
##################

cd /usr/local/src

if [ ! -f nagios-plugins-1.4.13.tar.gz ]; then
  wget http://heanet.dl.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.13.tar.gz
fi
if [ ! -d nagios-plugins-1.4.13 ]; then
  tar xvzf nagios-plugins-1.4.13.tar.gz
fi

# NAGIOS PLUGINS
cd nagios-plugins-1.4.13
make clean
./configure
make
make install
