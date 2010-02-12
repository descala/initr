class apache {

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
  if $operatingsystem == "Debian" {
    package { "ssl-cert":
      ensure => installed,
    }
  }

}

class apache::passenger {

  # this class assumes that you installed passenger and rails
  # from gems or your distro package manager
  apache::enmod { ["passenger.load","passenger.conf"]: }

}

