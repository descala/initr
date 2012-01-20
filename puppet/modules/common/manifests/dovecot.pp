class common::dovecot($db_name,$db_user,$db_passwd,$db_passwd_encrypt,$mail_location,$admin_mail) {

  case $operatingsystem {
    "Debian": { include common::dovecot::debian }
    "CentOS": { include common::dovecot::centos }
  }

}

