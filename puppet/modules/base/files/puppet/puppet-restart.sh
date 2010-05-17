#!/bin/bash
#
# Restart puppet, with a random sleep (max 20 min)
# to avoid all puppets restarting together
RANG=1200
time_to_sleep=$RANDOM
let "time_to_sleep %= $RANG"
sleep $time_to_sleep
/etc/init.d/puppet stop
/etc/init.d/puppet start
