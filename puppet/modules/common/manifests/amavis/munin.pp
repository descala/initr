class common::amavis::munin {

  case $operatingsystem {
    "Debian": { include common::amavis::munin::debian }
    "CentOS": { include common::amavis::munin::centos }
  }

}

