#!/bin/bash
#
# Restart puppet, with a random sleep (max 20 min)
# to avoid all puppets restarting together
RANG=1200
time_to_sleep=$RANDOM
let "time_to_sleep %= $RANG"
sleep $time_to_sleep
# if we want to run puppet only once,
# it may be a node with scarce resources
# and puppet should run with low priority
nice -n 19 /usr/sbin/puppetd -o
