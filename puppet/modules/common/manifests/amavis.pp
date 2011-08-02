class common::amavis($db_name,$db_passwd,$db_user) {

  case $operatingsystem {
    "Debian": { include common::amavis::debian }
    "CentOS": { include common::amavis::centos }
  }

}

