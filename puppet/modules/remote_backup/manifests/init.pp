class remote_backup {

  include common::sshkeys
  if array_includes($classes,"nagios::nsca_node") {
    remote_backup::nagios_check_log { "${remotebackup}_is_ok": }
  }

  package {
    ["backupninja","duplicity"]:
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

  # add server key to /etc/ssh/ssh_known_hosts
  Sshkey <<| tag == "${remote_backup_server_hash}_remote_backups_server" |>>

  # export an authorized key to server
  @@ssh_authorized_key {
    "remote backup for $fqdn":
      ensure => "present",
      key => $sshdsakey,
      type => "dsa",
      options => "no-port-forwarding",
      user => $remotebackup,
      target => "$remotebackups_path/$remotebackup/.ssh/authorized_keys",
      require => [ File["$remotebackups_path/$remotebackup"], User[$remotebackup] ],
      tag => "${remote_backup_server_hash}_remote_backup_client";
  }

  # user to do backups
  @@user {
    $remotebackup:
      ensure => $ensure,
      comment => "puppet managed, backups for $fqdn",
      home => "$remotebackups_path/$remotebackup",
      shell => "/bin/bash",
      tag => "${remote_backup_server_hash}_remote_backup_client";
  }

  @@file {
    "$remotebackups_path/$remotebackup":
      ensure => directory,
      owner => $remotebackup,
      group => $remotebackup,
      mode => 750,
      require => [User[$remotebackup],File[$remotebackups_path]],
      tag => "${remote_backup_server_hash}_remote_backup_client";
    "$remotebackups_path/$remotebackup/.ssh/authorized_keys":
      owner => $remotebackup,
      mode => 0640,
      tag => "${remote_backup_server_hash}_remote_backup_client";
    "$remotebackups_path/$remotebackup/.ssh":
      owner => $remotebackup,
      mode => 0700,
      tag => "${remote_backup_server_hash}_remote_backup_client";
    "/etc/munin/plugins/${remotebackup}":
      ensure => "/usr/share/munin/plugins/remotebackup_",
      tag => "${remote_backup_server_hash}_remote_backup_client";
  }

}
