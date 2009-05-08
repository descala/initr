# Class: gnulinux
#
# Class for all GNU/Linux based systems.
class gnulinux {

  $cron_service = $operatingsystem ? {
    Debian => cron,
    Gentoo => fcron,
    default => crond
  }

  case $initr_cron {
    "1": {
      service { "cron":
        name => $cron_service,
        hasrestart => true,
        hasstatus => false,
        path => "/etc/init.d/",
        ensure => running,
        enable => true,
      }
    }
    "0": {
      service { "cron":
        name => $cron_service,
        hasrestart => true,
        hasstatus => false,
        path => "/etc/init.d/",
        ensure => stopped,
        enable => false,
      }
    }
    default: {}
  }

  case $initr_nsca_node {
    "1": { include nagios::nsca_node }
    default: {}
  }

}
