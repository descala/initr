#!/bin/sh

# Starts a puppetmaster for development purposes

# If you have rails 2.3.2 installed and puppet 0.24.x, add this lines to puppetmasterd:
#
#  require 'rubygems'
#  gem 'rails', '2.2.2'
#

abspath=$(cd ${0%/*} && echo $PWD/${0##*/})
path_only=`dirname "$abspath"`

puppetmasterd --confdir $path_only --certname puppet --no-daemonize -l console -v $*
