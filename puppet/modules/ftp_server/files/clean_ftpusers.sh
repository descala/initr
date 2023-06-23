#!/bin/bash

##################
# Puppet managed #
##################

users=$(cat /etc/passwd | grep "^[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:/home/ftpusers/" | cut -d":" -f1)
for user in $users ; do
  if [ ! -d "/home/ftpusers/$user" ]; then
    userdel $user
  fi
done
