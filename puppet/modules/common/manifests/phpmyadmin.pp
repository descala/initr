class common::phpmyadmin($accessible_phpmyadmin="0", $blowfish_secret="") {

  $phpmyadmindir = $operatingsystem ? {
    Debian => "/etc/phpmyadmin",
    default => $lsbdistrelease ? {
      "5.4" => "/usr/share/phpMyAdmin",
      default => "/usr/share/phpmyadmin"
    }
  }

  #TODO: php_gd is for phpmyadmin?
  package {
    ["phpmyadmin",$php_gd]:
      ensure => installed,
      notify => Exec["apache reload"];
  }

  file {
    "$phpmyadmindir/config.inc.php":
      mode => 640,
      group => $httpd_user,
      require => [Package["phpmyadmin"],Package[$webserver1::httpd]],
      content => template("common/phpmyadmin/config.inc.php.erb");
    "$httpd_confdir/phpmyadmin.conf":
      mode => 640,
      group => $httpd_user,
      require => Package["phpmyadmin"],
      content => template("common/phpmyadmin/apache_phpmyadmin.conf.erb");
  }

  #TODO: remove this when all Debian have /usr/share/phpmyadmin/config.inc.php restaured
  if $operatingsystem == "Debian" {
    file {
      "/usr/share/phpmyadmin/config.inc.php":
        mode => 644,
        owner => root,
        group => root,
        source => "puppet:///modules/common/phpmyadmin/debian_config.inc.php",
    }
  }

}
