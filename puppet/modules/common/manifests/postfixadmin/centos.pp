class common::postfixadmin::centos inherits common::postfixadmin {
  file {
    "/usr/local/src/postfixadmin_install.sh":
      mode => 755,
      content => template("common/postfixadmin/install.sh.erb");
    "/usr/local/src/postfixadmin_tables.sql":
      mode => 600,
      content => template("common/postfixadmin/tables_centos.sql.erb"),
      require => File["/usr/local/src/postfixadmin_db.sql"];
    "/var/www/html/postfixadmin/config.inc.php":
      mode => 664,
      content => template("common/postfixadmin/config_centos.inc.php.erb"),
      require => Exec["/bin/bash /usr/local/src/postfixadmin_install.sh"];
#TODO: apache config?
  }
  exec {
    "/bin/bash /usr/local/src/postfixadmin_install.sh":
      require => [File["/usr/local/src/postfixadmin_install.sh"],Service[$httpd_service],File["/usr/local/src/postfixadmin_tables.sql"],Service[$mysqld]],
      unless => "test -d /var/www/html/postfixadmin";
  }

}
