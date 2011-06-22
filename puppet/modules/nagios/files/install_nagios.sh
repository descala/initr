#!/bin/bash
##################
# puppet managed #
##################

cd /usr/local/src

# DOWNLOAD, UNTAR
if [ ! -f nagios-3.0.3.tar.gz ]; then
  wget http://heanet.dl.sourceforge.net/sourceforge/nagios/nagios-3.0.3.tar.gz
fi
if [ ! -f nagios-plugins-1.4.13.tar.gz ]; then
  wget http://heanet.dl.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.13.tar.gz
fi
if [ ! -f nsca-2.7.2.tar.gz ]; then
  wget http://heanet.dl.sourceforge.net/sourceforge/nagios/nsca-2.7.2.tar.gz
fi
if [ ! -d nagios-3.0.3 ]; then
  tar xvzf nagios-3.0.3.tar.gz
fi
if [ ! -d nagios-plugins-1.4.13 ]; then
  tar xvzf nagios-plugins-1.4.13.tar.gz
fi
if [ ! -d nsca-2.7.2 ]; then
  tar xvzf nsca-2.7.2.tar.gz
fi

# NAGIOS
cd nagios-3.0.3
./configure --with-command-group=nagcmd --with-nagios-user=nagios --with-nagios-group=nagios
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf

# NAGIOS PLUGINS
cd ../nagios-plugins-1.4.13
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install

# NSCA
cd ../nsca-2.7.2
./configure
make all
mkdir /usr/local/nsca ; mkdir /usr/local/nsca/etc ; mkdir /usr/local/nsca/bin

cp src/nsca /usr/local/nsca/bin/

