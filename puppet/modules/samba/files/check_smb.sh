#!/bin/sh
##################
# Puppet managed #
##################

# check smb
if [ $# -ne 3 -a $# -ne 1 -a $# -ne 0 ]; then
  echo "  Usage: $0 [<server>] [<user> <password>]"
  echo "Example: $0 192.168.1.1"
  echo "Example: $0 192.168.1.1 Administrator mypassword"
  exit 3
fi


if [ $# -eq 3 ]; then
  server=$1
  user=$2
  pass=$3
  out=`smbclient -L \\\\\\\\$server -U $user%$pass 2>&1`
elif [ $# -eq 1 ]; then
  server=$1
  out=`smbclient -NL \\\\\\\\$server 2>&1`
else
  out=`smbclient -NL \\\\\\\\127.0.0.1 2>&1`
fi

if [ $? -eq 0 ] ; then
  echo "SMB OK"
  exit 0
fi

echo "CRITICAL - $out"
exit 2
