define remote_backup::nagios_check_log() {

  nagios::check { $name:
    command => "check_log -F /var/log/backupninja.log -O /var/log/old_backupninja.log -q Warning:\\|Error:\\|Fatal:\\|Halt:",
    minute => 0,
    hour => 7,
    freshness => 90000;
  }

}
