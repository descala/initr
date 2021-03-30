#! /bin/bash

LSCLUSTERS='/usr/bin/pg_lsclusters'
DUMPALL='/usr/bin/pg_dumpall'
PSQL='/usr/bin/psql'
DIR='/var/backups/postgres'
mkdir -p "$DIR"
cd "$DIR"

# list postgres clusters
CLUSTERS=$( $LSCLUSTERS -h | grep online | tr -s ' ' | cut -d" " -f 2,3 --output-delimiter=',' )

# store clusters info
$LSCLUSTERS > $DIR/clusters.txt

for l in $CLUSTERS ; do

  cluster=$(echo $l | cut -d"," -f1)
  port=$(echo $l | cut -d"," -f2)

  # get list of databases in cluster, exclude the tempate dbs
  DBS=( $($PSQL -p $port --list --tuples-only | awk '!/template[01]/ && $1 != "|" {print $1}') )

  # next dump globals (roles and tablespaces) only
  $DUMPALL --globals-only  > "$DIR/globals_$cluster.$port"

  # now loop through each individual database and backup the
  # schema and data separately
  for database in "${DBS[@]}" ; do
    pg_dump -p $port -f "$DIR/$database.$cluster.$port.backup" -F c -w "$database"
  done

done
