define nagios::check($command, $checkfreshness="1", $freshness="1800", $minute="*/5", $hour="*", $ensure="present", $notifications_enabled="1") {
  nagios::nsca_node::wrapper_check { $name:
    command => "$nagios_plugins_dir/$command",
    checkfreshness => $checkfreshness,
    freshness => $freshness,
    minute => $minute,
    hour => $hour,
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
  }
}

