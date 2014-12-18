#!/bin/bash

usage() {
  echo "usage: ${0##*/} [--no-sleep]"
  exit 3
}

until [ -z "$1" ]; do
  case "$1" in
    --no-sleep) nosleep=true
                ;;
             *) usage
                ;;
  esac
  shift
done

if [ -z "$nosleep" ]; then
  # random sleep (max 20 min)
  # to avoid all puppets restarting together
  RANG=1200
  time_to_sleep=$RANDOM
  let "time_to_sleep %= $RANG"
  sleep $time_to_sleep
fi

# if we want to run puppet only once,
# it may be a node with scarce resources
# and puppet should run with low priority
if [ -f /usr/sbin/puppetd ]; then
  nice -n 19 /usr/sbin/puppetd --test
else
  nice -n 19 /usr/bin/puppet agent --test
fi

exit 0
