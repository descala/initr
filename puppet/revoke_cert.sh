#!/bin/sh

# revoke a ssl certificate, called when node is deleted.
# This script expects that you configure incron to call it this way:
#   <PATH_TO_REDMINE_ROOT>/tmp/revoke_requests IN_CLOSE_WRITE <PATH_TO_THIS_SCRIPT>revoke_cert.sh $#

# Warning: apache needs restart to load new CRL:
# https://issues.apache.org/bugzilla/show_bug.cgi?id=14104

log() {
  if [ ! -z "`which logger`" -a ! -z "$1" ]; then
    logger -t "revoke_request" -- "$1"
  fi
}

if [ $# -ne 1 ]; then
  log "$0 expects 1 argument (called with $#)"
  exit 1
fi

echo `basename $1` | egrep "^revoke_.+$" &> /dev/null
if [ $? -ne 0 ]; then
  log "$0 expects revoke_xxx file (called for `basename $1`)"
  exit 1
fi

PATH=$PATH:/usr/local/sbin
token=`echo -n $(basename $1) | sed 's/^revoke_//'`
RAILS_ENV=`cat $(dirname $0)/../server_info.yml | grep RAILS_ENV | cut -d" " -f2`

abspath=$(cd ${0%/*} && echo $PWD/${0##*/})
path_only=`dirname "$abspath"`

if [ -z "`which puppetca`" ] ; then
  puppetca=`gem contents --prefix  puppet | grep "puppetca$"`
else
  puppetca="puppetca"
fi

if [ -z "$puppetca" ]; then
  log "Can't find puppetca executable"
  exit 1
fi

log "revoke request for $token"

if [ -z "$RUBYLIB" ]; then
  export RUBYLIB="$(echo -n `gem contents --prefix puppet |grep "/lib/puppet.rb$" |sed 's#/puppet.rb$##'`)"
fi

if [ "$RAILS_ENV" = "development" ]; then
  output=$($puppetca --confdir $path_only --revoke $token 2>&1)
else
  output=$($puppetca --revoke $token 2>&1)
fi

rm $1
log "$output"
