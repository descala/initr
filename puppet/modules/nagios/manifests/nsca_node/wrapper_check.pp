define nagios::nsca_node::wrapper_check($command, $checkfreshness="1", $freshness="1800", $minute="*/5", $hour="*", $ensure="present", $notifications_enabled="1",$sleep="--sleep") {

  nagios::service { $name:
    checkfreshness => $checkfreshness,
    freshness => $freshness,
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
  }

  # One script per check in /usr/local/sbin ("check-swap", "check-df", ...) so an
  # operator can re-run a check by hand, and push a fresh result to Nagios, without
  # copying the crontab line. cron runs the same script, adding --sleep to spread
  # the load. Initr only forbids single quotes in check names, so the file name
  # keeps [A-Za-z0-9._-] and turns anything else (e.g. spaces) into "_".
  $script_name = regsubst($name, '[^A-Za-z0-9._-]', '_', 'G')
  $check_script = "/usr/local/sbin/check-${script_name}"

  file { $check_script:
    ensure  => $ensure,
    mode    => '0744',
    content => template("nagios/nsca_check.erb"),
    require => File["/usr/local/bin/nsca_wrapper"],
  }

  $nsca_command = "$check_script $sleep > /dev/null 2>&1"

  # bug: http://projects.reductivelabs.com/issues/1728
  case $hour {
    "*": {
      cron { "nagios $name":
        command => $nsca_command,
        user => root,
        minute => $minute,
        require => File[$check_script],
        ensure => $ensure,
      }
    }
    default: {
      cron { "nagios $name":
        command => $nsca_command,
        user => root,
        minute => $minute,
        hour => $hour,
        require => File[$check_script],
        ensure => $ensure,
      }
    }
  }
}
