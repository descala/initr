class remote_backup::backupninja {

  if array_includes($classes,"nagios::nsca_node") {
    remote_backup::nagios_check_log { "${remotebackup}_is_ok": }
  }

  package {
    "backupninja":
      ensure => present;
  }

  file {
    "/etc/backupninja.conf":
      content => template("remote_backup/backupninja.conf.erb"),
      require => Package["backupninja"];
    "/etc/backup.d/90.dup":
      mode => 600,
      content => template("remote_backup/90.dup.erb"),
      require => Package["backupninja"];
  }

}
