class munin::server {

  include common::munin::server
  include common::apache

  file {
    "/etc/munin/munin.conf":
      ensure => present,
      content => template("munin/munin.conf.erb"),
      require => Package["munin"];
  }

}

