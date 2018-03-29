class nagios::server {

  case $operatingsystem {
    "Debian": {
      case $lsbdistcodename {
        dapper: { include nagios::server::redhat }
        stretch: { include nagios::server::debian_stretch }
        default: { include nagios::server::debian }
      }
    }
    default: { include nagios::server::redhat }
  }

}

