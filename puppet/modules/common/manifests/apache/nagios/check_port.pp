class common::apache::nagios::check_port {
  nagios::nsca_node::wrapper_check { "localhost_www":
    command => "$nagios_plugins_dir/check_http -I 127.0.0.1 -e HTTP/1."
  }
}

