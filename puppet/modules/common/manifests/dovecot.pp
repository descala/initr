class common::dovecot($db_name,$db_user,$db_passwd,$db_passwd_encrypt,$mail_location,$admin_mail) {

  case $operatingsystem {
    "Debian": {
      case $lsbmajdistrelease {
        "6": { include common::dovecot::debian6 }
        default: { include common::dovecot::debian7 }
      }
    "CentOS": { include common::dovecot::centos }
  }

}

