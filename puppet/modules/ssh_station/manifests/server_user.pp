class ssh_station::server_user {
  user { "sshst":
    comment => "Ssh station user",
    ensure => present,
    home => "/home/sshst",
    shell => $nologin;
  }
  file {
    "/home/sshst":
      ensure => directory,
      owner => "sshst", group => "sshst",
      require => User["sshst"];
    "/home/sshst/.ssh":
      ensure => directory,
      owner => "sshst", group => "sshst", mode => '0700',
      require => User["sshst"];
    "/home/sshst/.ssh/authorized_keys":
      mode => '0644',
      owner => "sshst", group => "sshst",
      require => User["sshst"],
      content => template("ssh_station/ssh_station_server_authorized_keys.erb");
  }
}

