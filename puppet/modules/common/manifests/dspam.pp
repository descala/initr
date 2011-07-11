class dspam($db_name,$db_user,$db_passwd,$db_passwd_encrypt_httpd) {

  #TODO: apache conf
  package {
    "mod_auth_mysql":
      ensure => installed;
  }
  service {
    "dspam":
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => File["/etc/init.d/dspam"];
  }
  file {
    "/usr/local/src/dspam_install.sh":
      mode => 744,
      source => "puppet:///modules/common/dspam/dspam_install.sh",
      require => [Package["clamav"],Package["gcc"]];
    "/usr/local/etc/dspam.conf":
      mode => 640,
      group => mail,
      source => "puppet:///modules/common/dspam/dspam.conf",
      notify => Service["dspam"];
    "/etc/init.d/dspam":
      mode => 755,
      source => "puppet:///modules/common/dspam/initd_dspam",
      notify => Exec["/sbin/chkconfig --add dspam"];
    "/etc/httpd/conf.d/spam.codifont.net.conf":
      mode => 640,
      group => $httpd_user,
      content => template("common/dspam/http_dspam.conf.erb"),
      notify => Service[$httpd_service];
    "/var/www/html/dspam/configure.pl":
      mode => 644,
      content => template("common/dspam/dspam_configure.pl.erb"),
      require => Exec["/usr/local/src/dspam_install.sh"];
  }
  exec {
    "/usr/local/src/dspam_install.sh":
      require => File["/usr/local/src/dspam_install.sh"],
      unless => "test -f /usr/local/bin/dspam";
    "/sbin/chkconfig --add dspam":
      refreshonly => true,
      require => File["/etc/init.d/dspam"];
  }
  cron {
    "dspam_cleanup":
      command => "/usr/local/bin/dspam_clean",
      user => dspam,
      hour => 1, minute => 0,
      require => Exec["/usr/local/src/dspam_install.sh"];
  }

}
