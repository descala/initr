class ssh_station::client_user {
  group { 'ssh_station':
    ensure => 'present';
  }
  case $operatingsystem {
    "Gentoo": {
      user { "ssh_station":
        require => Group['ssh_station'],
        comment => "Ssh station user",
        ensure => present,
        home => "/home/ssh_station",
        shell => "/bin/bash",
        gid => 'ssh_station',
        groups => "wheel"; # needed to exec "su"
      }
    }
    default: {
      user { "ssh_station":
        require => Group['ssh_station'],
        comment => "Ssh station user",
        ensure => present,
        home => "/home/ssh_station",
        gid => 'ssh_station',
        shell => "/bin/bash";
      }
    }
  }
  file {
    "/home/ssh_station":
      ensure => directory,
      owner => "ssh_station", group => "ssh_station",
      require => User["ssh_station"];
    "/home/ssh_station/.ssh":
      ensure => directory,
      owner => "ssh_station", group => "ssh_station", mode => '0700',
      require => User["ssh_station"];
    "/home/ssh_station/.ssh/authorized_keys":
      mode => '0644',
      owner => "ssh_station", group => "ssh_station",
      require => User["ssh_station"],
      content => template("ssh_station/operator_client_authorized_keys.erb");
  }
  exec {
    # generate dsa key for the user, this key will be authorized on ssh_station_server
    "ssh-keygen -t dsa -C 'Generated by Initr SshStation' -N '' -f /home/ssh_station/.ssh/id_dsa":
      user => "ssh_station",
      require => [ File["/home/ssh_station/.ssh"], User["ssh_station"] ],
      unless => "test -f /home/ssh_station/.ssh/id_dsa";
  }
}

