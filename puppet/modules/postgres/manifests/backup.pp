define postgres::backup($destination = "/var/arxiver/documents/sqlbackups", $hour = 4, $minute = 40) {

  cron { "$name backup":
    command => "/usr/bin/pg_dump $name > $destination/$name.sql",
    user => "postgres",
    hour => $hour, minute => $minute,
  }

  file { "/etc/logrotate.d/psql_backup_$name":
    owner => root,
    group => root,
    mode => '0644',
    content => template("postgres/logrotate_backups.erb"),
  }
}

