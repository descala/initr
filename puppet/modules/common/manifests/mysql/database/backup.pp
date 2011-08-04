define common::mysql::database::backup($destdir, $user, $pass, $hour="3", $min="0") {
  cron { "backup $name":
    command => "/bin/sleep \$[ ( \$RANDOM \\% 600  ) ] ; /usr/bin/mysqldump -u $user -p$pass $name > $destdir/$name.sql ; gzip -f $destdir/$name.sql ; chmod 600 $destdir/$name.sql.gz",
    user => root,
    hour => $hour,
    minute => $min,
  }
}

