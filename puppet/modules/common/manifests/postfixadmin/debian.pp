class common::postfixadmin::debian inherits common::postfixadmin {
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
    "/etc/postfixadmin/config.local.php":
      mode => 640, owner => root, group => www-data,
      require => Exec["install postfixadmin"],
      content => template("common/postfixadmin/config.local.php.erb");
    "$httpd_confdir/postfixadmin":
      ensure => "/etc/postfixadmin/apache.conf";
  }
}

