class smart::smartd inherits smart::smartd_conf_only {

  case $operatingsystem {
    "Debian": {
      Service[$::smartd_service] {
        name => smartmontools,
        require => [ Package[$smartd_packagename], File[smartd-notice] ],
        hasstatus => false,
        hasrestart => true,
        pattern => "smartd",
      }
      file { "/etc/default/smartmontools":
        content => "start_smartd=yes",
      }
    }
    "Mandriva": {
      warning("Mandriva: install smartmontools manually.")
    }
    default: {
      Service[$::smartd_service] {
        require => [ Package[$smartd_packagename], File[smartd-notice] ],
      }
    }
  }

  package { $smartd_packagename: 
    ensure => installed,
  }

  File['/etc/smartd.conf'] {
    require => Package[$smartd_packagename],
  }
  
  file { smartd-notice: 
    path => '/usr/local/bin/smartd.sh',
    mode => '0755',
    owner => root,
    group => root,
    source => "puppet:///modules/smart/smartd.sh",
    require => Package[$smartd_packagename],
  }

  nagios::service { "smartd":
    checkfreshness => "0",
  }

}

