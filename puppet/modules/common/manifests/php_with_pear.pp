class common::php_with_pear inherits common::php {
  package {
    "php-pear":
      ensure => installed,
      notify => Exec["apache reload"];
  }
}
