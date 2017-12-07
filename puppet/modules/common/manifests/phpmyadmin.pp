class common::phpmyadmin($accessible_phpmyadmin="0", $blowfish_secret="") {

  $phpmyadmindir = $operatingsystem ? {
    "Debian" => "/etc/phpmyadmin",
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

  if $operatingsystem == "Debian" and ($lsbmajdistrelease == "7" or $lsbmajdistrelease == "8") {
    file {
      "$phpmyadmindir/config.inc.php":
        mode    => "0640",
        group   => $httpd_user,
        require => [Package["phpmyadmin"],Package[$webserver1::httpd]],
        source  => "puppet:///modules/common/phpmyadmin/config.inc.php";
      "$httpd_confdir/phpmyadmin.conf":
        ensure  => "$phpmyadmindir/apache.conf";
    }
    if $lsbmajdistrelease == "8" {
      file {
        "/etc/apache2/conf-enabled/phpmyadmin.conf":
          ensure => 'link',
          target => '../conf-available/phpmyadmin.conf';
      }
    }
  } else {
    file {
      "$phpmyadmindir/config.inc.php":
        mode    => "0640",
        group   => $httpd_user,
        require => [Package["phpmyadmin"],Package[$webserver1::httpd]],
        content => template("common/phpmyadmin/config.inc.php.erb");
      "$httpd_confdir/phpmyadmin.conf":
        mode => "0640",
        group => $httpd_user,
        require => Package["phpmyadmin"],
        content => template("common/phpmyadmin/apache_phpmyadmin.conf.erb");
    }
  }
}
