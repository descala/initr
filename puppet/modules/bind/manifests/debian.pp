# debian specific
class bind::debian {

  file {
    "$bind::var_dir":
      owner => $bind::binduser,
      group => $bind::binduser,
      mode => 770,
      require => Package[$bind::bind],
      ensure => directory;
  }

  append_if_no_such_line { puppet_zones_include:
    file => "/etc/bind/named.conf.local",
    line => "include \"/etc/bind/puppet_zones.conf\"; // line added by puppet",
    require => Package[$bind::bind],
    notify => Service["bind"],
  }

}

