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

/etc/init.d/puppet stop
if [ -z "$nosleep" ]; then
  sleep 5
fi
/etc/init.d/puppet start

exit 0
