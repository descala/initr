class remote_backup::standalone {

  if array_includes($classes,"nagios::nsca_node") {
    nagios::service { "${remotebackup}_is_ok": }
  }

  package {
    "backupninja":
      ensure => absent;
  }

  file {
    "/usr/local/sbin/remote_backup.sh":
      content => template("remote_backup/remote_backup.sh.erb"),
      mode => 700, # key password on this file
      owner => root,
      group => root;
  }

  #TODO nagios_check for this log file
  cron {
    "remote backup":
      command => "/usr/local/sbin/remote_backup.sh &> /var/log/remote_backup.log",
      user => root,
      hour => 0,
      minute => 0;
  }
}
