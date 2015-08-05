class nagios::nsca_node {
  case $operatingsystem {
    Debian: {
      case $lsbdistcodename {
        # dapper has bug in package nagios-plugins-basic (check_procs plugin)
        dapper: { include nagios::nsca_node::redhat }
        default: { include nagios::nsca_node::debian }
      }
    }
    Ubuntu: {
      include nagios::nsca_node::debian
      }
    default: { include nagios::nsca_node::redhat }
  }
  case $raidtype {
    "software",
    "software,hardware",
    "software hardware": {
      include nagios::swraid
    }
  }
}

