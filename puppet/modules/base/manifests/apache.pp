class apache {

  if array_includes($classes,"nagios::nsca_node") {
    include apache::nagios
  }

  package { $httpd:
    ensure => installed,
  }

  service { $httpd_service:
    ensure => running,
    enable => true,
    require => Package[$httpd],
  }

  # debian a2enmod, but just one symlink
  # should be called with file extension (.load or .conf)
  # once for each file needed by module
  define enmod() {
    file { "/etc/apache2/mods-enabled/$name":
      ensure => "../mods-available/$name",
      require => Package[$httpd],
      notify => Service[$httpd_service];
    }
  }
  # debian a2dismod
  define dismod() {
    file { ["/etc/apache2/mods-enabled/${name}.conf","/etc/apache2/mods-enabled/${name}.load"]:
      ensure => absent,
      require => Package[$httpd],
      notify => Service[$httpd_service];
    }
  }
  # debian a2ensite
  define ensite() {
    if $name == "default"
    {
      # ensures default is loaded as the first virtualhost
      file { "/etc/apache2/sites-enabled/000-default":
        ensure => "../sites-available/default",
        require => Package[$httpd],
        notify => Service[$httpd_service];
      }
    }
    else
    {
      file { "/etc/apache2/sites-enabled/$name":
        ensure => "../sites-available/$name",
        require => Package[$httpd],
        notify => Service[$httpd_service];
      }
    }
  }
  # debian a2dissite
  define dissite() {
    file { ["/etc/apache2/sites-enabled/$name","/etc/apache2/sites-enabled/000-$name"]:
      ensure => absent,
      require => Package[$httpd],
      notify => Service[$httpd_service];
    }
  }

}

class apache::ssl inherits apache {

  if $ssl_module != "" {
    package { $ssl_module:
      ensure => installed,
    }
  }

  # generates self-signed certs
  case $lsbdistid {
    "Debian","Ubuntu": {
      package { "ssl-cert":
        ensure => installed,
      }
    }
  }

}

class apache::nagios {
  if $apache_procs_warn {
    $warn=$apache_procs_warn
  } else {
    $warn="50"
  }
  if $apache_procs_crit {
    $crit=$apache_procs_crit
  } else {
    $crit="100"
  }
  nagios::nsca_node::wrapper_check { "apache":
    command => "$nagios_plugins_dir/check_procs -C $httpd_service -w 1:$warn -c 1:$crit",
  }
  include apache::nagios::check_port
}

class apache::nagios::check_port {
  nagios::nsca_node::wrapper_check { "localhost_www":
    command => "$nagios_plugins_dir/check_http -I 127.0.0.1 -e HTTP/1."
  }
}

class apache::passenger {

  # this class assumes that you installed passenger and rails
  # from gems or your distro package manager
  apache::enmod { ["passenger.load","passenger.conf"]: }

}

