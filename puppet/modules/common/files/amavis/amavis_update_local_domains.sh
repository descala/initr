#!/bin/bash

/usr/bin/mysql postfix --skip-column-names -s -e "select domain from domain where domain like '%.%';" > /tmp/domains

if [ -e /tmp/domains ] ; then
    chmod 600 /tmp/domains
    # exit if nothing changed
    cmp -s /tmp/domains /etc/amavis/local_domains && exit
    mv /tmp/domains /etc/amavis/local_domains && /usr/sbin/service amavis restart > /dev/null
fi
