define remote_backup::nagios_check() {

  nagios::check { "${name}_is_current":
    # 129600 = 36h // 172800 = 48h
    command => "check_newest_file_age $remotebackups_path/$name 129600 172800",
    minute => 5,
    hour => '*/4', # every four hours
    freshness => 43200,
  }

}
