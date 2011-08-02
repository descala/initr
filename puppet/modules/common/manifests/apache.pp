class common::apache {

  if array_includes($classes,"nagios::nsca_node") {
    include common::apache::nagios
  }
  if array_includes($classes,"munin") {
    include common::apache::munin
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

