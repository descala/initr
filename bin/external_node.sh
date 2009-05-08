#!/bin/sh

DOMAIN=`cat $(dirname $0)/../server_info.yml | grep DOMAIN | cut -d" " -f2`
/usr/bin/wget -O - -q http://$DOMAIN/node/get_host_definition?hostname=$1
