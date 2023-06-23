#!/bin/bash

users=$(grep "^initr_" /etc/passwd | cut -d":" -f1)
for user in $users ; do
  if [ ! -d "/home/ssh_station_operators/$user" ]; then
    userdel $user
  fi
done
