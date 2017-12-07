class nagios::server {

  case $operatingsystem {
    "Debian": {
      case $lsbdistcodename {
        dapper: { include nagios::server::redhat }
        default: { include nagios::server::debian }
      }
    }
    default: { include nagios::server::redhat }
  }

}

