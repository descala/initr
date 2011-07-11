class postfixadmin($db_name,$db_user,$db_passwd,$postfixadmin_user,$postfixadmin_passwd,$admin_email,$db_passwd_encrypt,$bak_host) {

  case $operatingsystem {
    "Debian": { include postfixadmin::debian }
    "CentOS": { include postfixadmin::centos }
  }

  file {
    # creates empty database and grants access to postfixadmin user
    "/usr/local/src/postfixadmin_db.sql":
      mode => 600,
      content => template("common/postfixadmin/db.sql.erb");
  }
}

class postfixadmin::debian inherits postfixadmin {
  package {
    ["dbconfig-common","wwwconfig-common"]:
      ensure => present;
  }
  exec {
    "install postfixadmin":
      unless => "dpkg -l postfixadmin | grep -q '^ii  postfixadmin'",
      command => "/bin/bash /usr/local/src/postfixadmin_install.sh",
      require => [File["/usr/local/src/postfixadmin_install.sh"],
                  File["/usr/local/src/postfixadmin_db.sql"],
                  File["/usr/local/src/postfixadmin.debconf_selections"]];
  }
  file {
    "/usr/local/src/postfixadmin.debconf_selections":
      source => "puppet:///modules/common/postfixadmin/postfixadmin.debconf_selections";
    "/usr/local/src/postfixadmin_install.sh":
      mode => 755,
      content => template("common/postfixadmin/install.sh.erb");
    "/usr/local/src/postfixadmin_tables.sql":
      mode => 600,
      source => "puppet:///modules/common/postfixadmin/tables_debian.sql",
      require => File["/usr/local/src/postfixadmin_db.sql"];
    "/etc/postfixadmin":
      ensure => directory;
    "/etc/postfixadmin/config.inc.php":
      mode => 640, owner => root, group => www-data,
      require => Exec["install postfixadmin"],
      content => template("common/postfixadmin/config_debian.inc.php.erb");
    "$httpd_confdir/postfixadmin":
      ensure => "/etc/postfixadmin/apache.conf";
  }
}

class postfixadmin::centos inherits postfixadmin {
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
