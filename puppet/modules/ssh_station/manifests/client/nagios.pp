class ssh_station::client::nagios {
  nagios::nsca_node::wrapper_check { "ssh_station_connected":
    command => "$nagios_plugins_dir/check_ssh -p 7783 localhost",
    notifications_enabled => "0",
  }
}

