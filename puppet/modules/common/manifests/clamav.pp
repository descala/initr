class common::clamav {

  include common::decompressors

  case $operatingsystem {
    "Debian": { include common::clamav::debian }
    "CentOS": { include common::clamav::centos }
  }

}

