class common::clamav {

  case $operatingsystem {
    "Debian": { include common::clamav::debian }
    "CentOS": { include common::clamav::centos }
  }

}

