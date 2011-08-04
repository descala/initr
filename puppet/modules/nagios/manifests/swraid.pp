class nagios::swraid {
  file {
    "$nagios_plugins_dir/check_swraid":
      mode => 755,
      source => "puppet:///modules/nagios/check_swraid";
  }
  nagios::nsca_node::wrapper_check {
    "sw_raid":
      command => "$nagios_plugins_dir/check_swraid";
  }
}

