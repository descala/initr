class ssh_station::sysv_client inherits ssh_station::client {
  exec { "restart_ssh_station":
      command => "telinit q",
      subscribe => Append_if_no_such_line["inittabssh"],
      refreshonly => true;
  }
  append_if_no_such_line { 'inittabssh':
    file => "/etc/inittab",
    line => "ss:2345:respawn:/usr/local/sbin/ssh_station",
    require => [ File["/etc/ssh/ssh_config"], File["ssh_station"] ];
  }
}
