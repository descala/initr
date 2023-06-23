class ssh_station::ssh {

  include common::openssh

  file {
    "/etc/ssh/ssh_config":
      mode => '0644',
      owner => root,
      group => root,
      content => template("ssh_station/ssh_config.erb");
  }
}

