define remote_backup::nagios_check_disk_used($threshold) {

  nagios::check { "${name}_disk_used":
    command => "check_disk_used $remotebackups_path/$name $threshold",
    minute => 1,
    hour => 7,
    freshness => 90000;
  }

}
