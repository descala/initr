class common::apache::nagios {
  if $apache_procs_warn {
    $warn=$apache_procs_warn
  } else {
    $warn="50"
  }
  if $apache_procs_crit {
    $crit=$apache_procs_crit
  } else {
    $crit="100"
  }
  nagios::nsca_node::wrapper_check { "apache":
    command => "$nagios_plugins_dir/check_procs -C $httpd_service -w 1:$warn -c 1:$crit",
  }
  include common::apache::nagios::check_port
}

