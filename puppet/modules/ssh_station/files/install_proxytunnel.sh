#!/bin/bash
##################
# Puppet managed #
##################

cd /usr/local/src

if [ ! -f proxytunnel-1.9.0.tgz ]; then
    wget http://downloads.sourceforge.net/project/proxytunnel/proxytunnel%20source%20tarballs/proxytunnel%201.9.0/proxytunnel-1.9.0.tgz?use_mirror=freefr
fi

if [ ! -d proxytunnel-1.9.0 ]; then
    tar xvzf proxytunnel-1.9.0.tgz
fi

cd proxytunnel-1.9.0

make
make install
