class common::php {
  $packages = $operatingsystem ? {
    "Debian" => ["php5"],
    default => ["php","php-eaccelerator"]
  }
  package {
    $packages:
      ensure => installed,
      notify => Exec["apache reload"];
  }

  # define php_packages($packages) {
  #   package {
  #     $packages:
  #       ensure => installed,
  #       notify => Exec["apache reload"];
  #   }
  # }

  # case $operatingsystem {
  #   "Debian": {
  #     case $lsbmajdistrelease {
  #       "8", "9": { php_packages(["php5", "php5-mysqlnd"]) }
  #       default:  { php_packages(["php5", "php5-mysql"]) }
  #     }
  #   }
  #   default: { php_packages(["php","php-eaccelerator","php-mysql"]) }
  # }
}
