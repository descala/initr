#!/bin/sh
# Notifies an smartd event to nagios
VAL=`echo "$SMARTD_MESSAGE" | grep "TEST EMAIL" >/dev/null ; echo $?`
/usr/local/bin/nsca_send "smartd\t$VAL\t$SMARTD_MESSAGE" >/dev/null 2>&1
exit 0
