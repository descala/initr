class common::php_with_pear inherits common::php {
  package {
    "php-pear":
      ensure => installed,
      notify => Service[$httpd_service];
  }
}
