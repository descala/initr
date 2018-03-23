class common::postfixadmin::debian::stretch {

  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=856338
  file {
    '/usr/share/postfixadmin/templates_c':
      ensure => directory,
      owner  => $httpd_user;
  }

}

