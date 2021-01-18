#! /bin/bash

DUMPALL='/usr/bin/pg_dumpall'
PSQL='/usr/bin/psql'
DIR='/var/backups/postgres'
mkdir -p "$DIR"
cd "$DIR"

# get list of databases in system , exclude the tempate dbs
DBS=( $($PSQL --list --tuples-only |
awk '!/template[01]/ && $1 != "|" {print $1}') )

# next dump globals (roles and tablespaces) only
$DUMPALL --globals-only  > "$DIR/globals"

# now loop through each individual database and backup the
# schema and data separately
for database in "${DBS[@]}" ; do
    pg_dump -f "$DIR/$database.backup" -F c -w "$database"
done
