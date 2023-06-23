#!/bin/bash
##################
# puppet managed #
##################

cd /usr/local/src

if [ ! -f nagios-plugins-2.3.3.tar.gz ]; then
  wget http://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
fi
if [ ! -d nagios-plugins-2.3.3 ]; then
  tar xvzf nagios-plugins-2.3.3.tar.gz
fi

# NAGIOS PLUGINS
cd nagios-plugins-*
make clean
./configure
make
make install
