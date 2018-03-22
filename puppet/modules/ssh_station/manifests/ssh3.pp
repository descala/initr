class ssh_station::ssh3 inherits ssh_station::ssh {
  File["/etc/ssh/ssh_config"] {
    content => template("ssh_station/ssh_config_v3.erb"),
  }
}

