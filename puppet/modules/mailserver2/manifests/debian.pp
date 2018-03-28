class mailserver2::debian inherits mailserver2::common {
  #TODO: php-mbstring on Debian?
  package {
    "php5-imap":
      ensure => installed,
      notify => Service[$httpd_service];
    ["libgd-graph3d-perl","postfix-mysql","postfix-pcre"]:
      require => Package["postfix"],
      ensure => installed;
  }
  file {
    "/etc/postfix/master.cf":
      mode => '0644',
      source => [ "puppet:///specific/postfix-master.cf", "puppet:///modules/mailserver2/master_debian.cf" ],
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/main.cf":
      mode => '0644',
      source => [ "puppet:///specific/postfix-main.cf", "puppet:///modules/mailserver2/main_debian.cf" ],
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/apache2/conf.d/squirrelmail.conf":
      ensure => "/etc/squirrelmail/apache.conf",
      notify => Service[$httpd_service];
  }
}

