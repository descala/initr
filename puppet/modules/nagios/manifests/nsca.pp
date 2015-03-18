class nagios::nsca {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        dapper: { include "nagios::nsca::redhat" }
        default: { include "nagios::nsca::debian" }
      }
    }
    Ubuntu: {
      include nagios::nsca::debian
      }
    default: { include "nagios::nsca::redhat" }
  }
}

