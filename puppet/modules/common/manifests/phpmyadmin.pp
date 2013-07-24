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

  if $operatingsystem == "Debian" and $lsbdistrelease == "7" {
    file {
      "$phpmyadmindir/config.inc.php":
        mode    => 640,
        group   => $httpd_user,
        require => [Package["phpmyadmin"],Package[$webserver1::httpd]],
        source  => "puppet:///modules/common/phpmyadmin/config.inc.php";
    }
  } else {
    file {
      "$phpmyadmindir/config.inc.php":
        mode    => 640,
        group   => $httpd_user,
        require => [Package["phpmyadmin"],Package[$webserver1::httpd]],
        content => template("common/phpmyadmin/config.inc.php.erb");
    }
  }

  file {
    "$httpd_confdir/phpmyadmin.conf":
      mode => 640,
      group => $httpd_user,
      require => Package["phpmyadmin"],
      content => template("common/phpmyadmin/apache_phpmyadmin.conf.erb");
  }
}
