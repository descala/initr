class common::apache {

  if array_includes($classes,"nagios::nsca_node") {
    include common::apache::nagios
  }
  if array_includes($classes,"munin::server") {
    include common::apache::munin
  }

  include common::apache::logrotate

  package { $httpd:
    ensure => installed,
  }

  service { $httpd_service:
    ensure => running,
    enable => true,
    require => Package[$httpd],
  }

  exec {
    "apache reload":
      command => "/etc/init.d/$httpd_service reload",
      refreshonly => true,
      require => Service[$httpd_service];
  }

}

