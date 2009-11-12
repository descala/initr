class php {
  package {
    ["php","php-eaccelerator","php-mysql"]:
      ensure => installed,
      notify => Service[$httpd_service];
  }
}

class php_with_pear inherits php {
  package {
    "php-pear":
      ensure => installed,
      notify => Service[$httpd_service];
  }
}
