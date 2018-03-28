#!/bin/bash
##################
# Puppet managed #
##################

# check winbind
if [ $# -ne 0 -a $# -ne 1 ]; then
  echo "  Usage: $0 [min_groups_size]"
  exit 3
fi

ok() {
  echo "winbind OK"
  exit 0
}

critical() {
  echo "CRITICAL - $1"
  exit 2
}

out=`wbinfo -p 2>&1` # check if winbind is running
if [ $? -eq 0 ]; then
  if [ $# -eq 1 ]; then
    out=`wbinfo -g 2>&1` # fetch winbind groups
    if [ $? -eq 0 ]; then
      out=`echo "$out" | wc -l 2>&1` # check how many groups winbind returned
      if [ $out -ge $1 ]; then
        ok
      else
        critical "only $out groups returned"
      fi
    else
      critical "$out"
    fi
  else
    ok
  fi
fi

critical "$out"
