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

}

