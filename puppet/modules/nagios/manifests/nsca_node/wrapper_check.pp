define nagios::nsca_node::wrapper_check($command, $checkfreshness="1", $freshness="1800", $minute="*/5", $hour="*", $ensure="present", $notifications_enabled="1",$sleep="--sleep") {

  nagios::service { $name:
    checkfreshness => $checkfreshness,
    freshness => $freshness,
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
  }

  $nsca_command = "/usr/local/bin/nsca_wrapper -H $fqdn -S '$name' -C '$command' $sleep -b $send_nsca -c $send_nsca_cfg &> /dev/null"

  # bug: http://projects.reductivelabs.com/issues/1728
  case $hour {
    "*": {
      cron { "nagios $name":
        command => $nsca_command,
        user => root,
        minute => $minute,
        require => File["/usr/local/bin/nsca_wrapper"],
        ensure => $ensure,
      }
    }
    default: {
      cron { "nagios $name":
        command => $nsca_command,
        user => root,
        minute => $minute,
        hour => $hour,
        require => File["/usr/local/bin/nsca_wrapper"],
        ensure => $ensure,
      }
    }
  }
}

