define nagios::check($command, $checkfreshness="1", $freshness="1800", $minute="*/5", $hour="*", $ensure="present", $notifications_enabled="1") {

  # "ssh" (check_ssh -H localhost) reports CRITICAL whenever sshd's pre-auth
  # slots are full -- "Server answer: Exceeded MaxStartups", or an empty
  # "Server answer:" on the OpenSSH versions that drop without a banner. That
  # is the chronic distributed brute-force against the farm, not an outage:
  # sshd is alive and the next 5-minute cycle answers OK again. With the
  # default template (max_check_attempts 1) a single bad sample is already a
  # hard state, so each blip mails twice per contact -- 18% of everything niu
  # sent on 2026-09-14, and 82% of those episodes were one sample long. The
  # tolerant template waits for 3 consecutive failures, i.e. a saturation long
  # enough to really break admin access. A real down (sshd stopped, port
  # closed) fails every attempt and still alerts.
  $service_template = $name ? {
    "ssh"   => "passive_service_tolerant",
    default => "passive_service",
  }

  nagios::nsca_node::wrapper_check { $name:
    command => "$nagios_plugins_dir/$command",
    use => $service_template,
    checkfreshness => $checkfreshness,
    freshness => $freshness,
    minute => $minute,
    hour => $hour,
    ensure => $ensure,
    notifications_enabled => $notifications_enabled,
  }
}

