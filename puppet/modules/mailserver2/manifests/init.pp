class mailserver2 {

  case $operatingsystem {
    "Debian": { include mailserver2::debian }
    "CentOS": { include mailserver2::centos }
  }

}

