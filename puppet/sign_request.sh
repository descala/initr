#!/bin/sh

# signs a ssl request if it has a initr node with the same name.
# This script expects that you configure incron to call it this way:
#   <PATH_TO_PUPPET_SSL_DIR>/ca/requests IN_CLOSE_WRITE <PATH_TO_THIS_SCRIPT>sign_request.sh $#

DOMAIN=`cat $(dirname $0)/../server_info.yml | grep DOMAIN | cut -d" " -f2`
RAILS_ENV=`cat $(dirname $0)/../server_info.yml | grep RAILS_ENV | cut -d" " -f2`

token="`echo -n "$1" | sed 's/\.pem$//'`"
valid="`curl -s -k $DOMAIN/install/can_sign/$token`"
abspath=$(cd ${0%/*} && echo $PWD/${0##*/})
path_only=`dirname "$abspath"`

log() {
  if [ ! -z "`which logger`" -a ! -z "$1" ]; then
    logger -t "sign_request" -- "$1"
  fi
}

if [ "$valid" != "true" ]; then
  log "Rejecting invalid signature request token: $token"
  exit 1
fi

if [ -z "`which puppetca`" ] ; then
  puppetca=`gem contents --prefix  puppet | grep "puppetca$"`
else
  puppetca="puppetca"
fi

if [ -z "$RUBYLIB" ]; then
  export RUBYLIB="$(echo -n `gem contents --prefix puppet |grep "/lib/puppet.rb$" |sed 's#/puppet.rb$##'`)"
fi

if [ "$RAILS_ENV" = "development"]; then
  output=$($puppetca --confdir $path_only --sign $token 2>&1)
else
  output=$($puppetca --sign $token 2>&1)
fi

log "$output"
