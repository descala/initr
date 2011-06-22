class nagios::nsca {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        dapper: { include "nagios::nsca::redhat" }
        default: { include "nagios::nsca::debian" }
      }
    }
    default: { include "nagios::nsca::redhat" }
  }
}

class nagios::nsca::debian {
  package {
    "nsca":
      ensure => present;
  }
}

class nagios::nsca::redhat {
  file {
    "/usr/local/src/install_nsca.sh":
      mode => 744,
      source => "puppet:///modules/nagios/install_nsca.sh";
  }
  exec {
    "/usr/local/src/install_nsca.sh":
      require => [ File["/usr/local/src/install_nsca.sh"], Package["gcc"] ],
      unless => "[ -f /usr/local/nsca/bin/send_nsca ]";
  }
}

