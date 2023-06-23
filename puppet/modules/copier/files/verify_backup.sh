#!/bin/bash
#
# comprova si hi ha fitxers modificats recentment en un directori
#

if [ $# -eq 1 ]; then
  DIR=$1
  CTIME=1
elif [ $# -eq 2 ]; then
  DIR=$1
  CTIME=$2
else
  echo "usage: $0 directory [ days_ago ]"
  exit 1
fi

# automount
ls $DIR > /dev/null 2>&1
sleep 10

find $DIR -ctime -$CTIME -exec killall find \; >> /var/log/arxiver 2>&1

if [ $? -eq 0 ]; then
  echo "[ $(date) ] No hi ha canvis a $DIR des de fa $CTIME dies, comprovar les copies." >> /var/log/arxiver 2>&1
  /usr/local/guaita/guaita-send.pl -m unmodified_backups_dir:1 >> /var/log/arxiver 2>&1
else
  /usr/local/guaita/guaita-send.pl -m unmodified_backups_dir:0 >> /var/log/arxiver 2>&1
fi

# fitxer per que es copii a la seguent copia programada, aixi sempre es copiara alguna cosa mentre funcioni el backup
echo "# Ingent: fitxer generat automaticament per controlar les copies de seguretat. " > /var/arxiver/.last_copy
