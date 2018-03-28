class ldap {

  package {
    $ldap:
      ensure => installed;
    "smbldap-tools":
      ensure => installed;
  }

  case $operatingsystem {
    Debian: {
      service { "$ldap_service":
        enable => true,
        ensure => running,
        hasrestart => true,
        hasstatus => false,
        require => File[$ldap_conf_file],
      }
    }
    default: {
      service { "$ldap_service":
        enable => true,
        ensure => running,
        hasrestart => true,
        hasstatus => true,
        require => File[$ldap_conf_file],
      }
    }
  }

  cron { "ldap-bak":
    command => "/usr/sbin/slapcat -l /var/arxiver/backup-ldap.ldif >/dev/null 2>&1",
    user => root,
    hour => 4,
    minute => 30,
  }

  file { $ldap_conf_file:
    owner => root,
    group => $ldap_user,
    mode => '0640',
    source => "puppet:///specific/slapd.conf",
    notify => Service[$ldap_service],
    require => Package[$ldap],
  }
}
