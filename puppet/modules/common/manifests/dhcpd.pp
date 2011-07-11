#########
# dhcpd #
#########

class dhcpd {

  package { $dhcp_package:
    ensure => "installed",
  }

  service { $dhcp_service:
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package[$dhcp_package],
  }

  file { $dhcp_conf:
    mode => 644,
    source => [ "puppet:///dist/specific/$fqdn/dhcpd.conf"],
    require => Package[$dhcp_package],
    notify => Service[$dhcp_service],
  }

}

