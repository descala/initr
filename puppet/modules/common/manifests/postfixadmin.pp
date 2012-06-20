class common::postfixadmin($db_name,$db_user,$db_passwd,$postfixadmin_user,$postfixadmin_passwd,$admin_email,$db_passwd_encrypt,$bak_host,$domain_in_mailbox,$domain_path) {

  case $operatingsystem {
    "Debian": { include common::postfixadmin::debian }
    "CentOS": { include common::postfixadmin::centos }
  }

  file {
    # creates empty database and grants access to postfixadmin user
    "/usr/local/src/postfixadmin_db.sql":
      mode => 600,
      content => template("common/postfixadmin/db.sql.erb");
  }
}

