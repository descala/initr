define ssh_station::server::operator_user($pubkey,$nodes) {

  $username="initr_$name"

  user { $username:
    ensure => present,
    comment => "Ssh station operator",
    home => "/home/ssh_station_operators/$username",
    shell => "/usr/local/bin/${username}_login";
  }

  file {
    "/usr/local/bin/${username}_login":
      mode => '0750',
      owner => root, group => $username,
      content => template("ssh_station/operator_login.erb");
    "/home/ssh_station_operators/$username":
      ensure => directory,
      owner => $username, group => $username,
      require => User[$username];
    "/home/ssh_station_operators/$username/.ssh":
      ensure => directory,
      owner => $username, group => $username, mode => '0700',
      require => User[$username];
    "/home/ssh_station_operators/$username/.ssh/config":
      owner => $username, group => $username, mode => '0644',
      content => template("ssh_station/operator_sshconfig.erb"),
      require => User[$username];
  }

  # generate RSA key for the user, this key will be authorized on ssh_station clients
  exec {
    "ssh-keygen -t rsa -C '$username' -N '' -f /home/ssh_station_operators/$username/.ssh/id_rsa":
      user => $username,
      require => [ File["/home/ssh_station_operators/$username/.ssh"], User[$username] ],
      unless => "test -f /home/ssh_station_operators/$username/.ssh/id_rsa";
  }

  # key provided by the user to redmine (authorized on server)
  ssh_authorized_key { "${username}_user_key":
    ensure => present,
    key => hash_value($pubkey,"key"),
    options => undef,
    type => hash_value($pubkey,"type"),
    user => $username,
    require => File["/home/ssh_station_operators/$username/.ssh"],
    target => "/home/ssh_station_operators/$username/.ssh/authorized_keys"
  }
}

