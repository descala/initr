class remote_backup::server::nagios {

  remote_backup::nagios_check_backup_files { $remote_backups: }

  create_resources(remote_backup::nagios_check_disk_used, $remote_backups_disk_usage_checks)

  file {
    "$nagios_plugins_dir/check_newest_file_age":
      mode => 755,
      source => "puppet:///modules/remote_backup/check_newest_file_age";
    "$nagios_plugins_dir/check_disk_used":
      mode => 755,
      source => "puppet:///modules/remote_backup/check_disk_used";
  }

}
