# smartmontools
class smart::smartd_conf_only {

  file { '/etc/smartd.conf':
    mode    => '0644',
    owner   => root,
    group   => root,
    content => template('smart/smartd.erb'),
    notify  => Service[$::smartd_service],
  }

  service { $::smartd_service:
    ensure => running,
    enable => true,
  }

}
