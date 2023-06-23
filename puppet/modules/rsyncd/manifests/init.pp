class rsyncd {

  include common::rsync

  service {
    "rsync":
      ensure => running,
      hasstatus => false,
      pattern => "rsync.*--daemon",
      require => File["/etc/default/rsync"];
  }

  file {
    "/etc/default/rsync":
      source => "puppet:///modules/rsyncd/default_rsync";
    "/etc/rsyncd.conf":
      content => template("rsyncd/rsyncd.conf.erb"),
      notify => Service["rsync"];
    "/etc/rsyncd.secrets":
      owner => root, mode => '0600',
      content => template("rsyncd/rsyncd.secrets.erb"),
      notify => Service["rsync"];
  }

}
