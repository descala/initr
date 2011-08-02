class common::php {
  $packages = $operatingsystem ? {
    Debian => ["php5", "php5-mysql"],
    default => ["php","php-eaccelerator","php-mysql"]
  }
  package {
    $packages:
      ensure => installed,
      notify => Service[$httpd_service];
  }
}

