define remote_backup::nagios_check_disk_used($threshold, $folder) {

  nagios::check { "${folder}_disk_used":
    command => "check_disk_used $name $remotebackups_path/$folder $threshold",
    minute => 1,
    hour => 7,
    freshness => 90000;
  }

}
