# set system time
class ntp {
  package { $ntp:
    ensure => installed,
  }
  case $operatingsystem {
    "Debian": {
      case $lsbdistid {
        "Ubuntu": {
          service { $ntp:
            enable => true,
            ensure => running,
            require => [ Package[$ntp], File["/etc/default/ntp"] ],
            pattern => ntpd,
            hasstatus => false,
          }
        }
        default: {
          service { $ntp:
            enable => true,
            ensure => running,
            require => [ Package[$ntp], File["/etc/default/ntp"] ],
          }
        }
      }
      file { "/etc/default/ntp":
        mode => 644,
		owner => root,
		group => root,
		source => [ "puppet:///dist/specific/$fqdn/ntp", "puppet:///modules/common/ntp_debian" ],
        require => Package[$ntp],
        notify => Service[$ntp],
      }
    }
    default:
    {
      file { "/etc/ntp/step-tickers":
        mode => 644,
        owner => root,
        group => root,
        source => [ "puppet:///dist/specific/$fqdn/ntp", "puppet:///modules/common/ntp" ],
        require => Package["ntp"],
      }
      service { "ntpd":
        enable => true,
        ensure => running,
        subscribe => File["/etc/ntp/step-tickers"],
        require => [ Package["ntp"], File["/etc/ntp/step-tickers"] ],
      }
    }
  }
}
