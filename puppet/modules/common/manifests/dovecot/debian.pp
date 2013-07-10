class common::dovecot::debian inherits common::dovecot::common {

  package { ["dovecot-imapd","dovecot-pop3d"]:
    ensure => installed,
  }

  Service[dovecot] { require => [Package["dovecot-imapd"],Package["dovecot-pop3d"]] }

  file {
    "/etc/pam.d/dovecot":
      ensure => absent;
    "/etc/dovecot/dovecot.conf":
      mode => 644,
      group => dovecot,
      source => "puppet:///modules/common/dovecot/dovecot_debian.conf",
      notify => Service["dovecot"],
      require => [Package["dovecot-imapd"],Package["dovecot-pop3d"]];
    "/etc/dovecot/dovecot-sql.conf":
      mode => 600, # This file contains the database password
      content => template("common/dovecot/dovecot-sql.conf.erb"),
      notify => Service["dovecot"],
      require => [Package["dovecot-imapd"],Package["dovecot-pop3d"]];
    "/etc/dovecot/dovecot-dict-sql.conf":
      mode => 640, # This file contains the database password
      group => dovecot,
      content => template("common/dovecot/dovecot-dict-sql.conf.erb"),
      notify => Service["dovecot"],
      require => [Package["dovecot-imapd"],Package["dovecot-pop3d"]];
  }
}

