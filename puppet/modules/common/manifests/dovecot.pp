class dovecot($db_name,$db_user,$db_passwd,$db_passwd_encrypt) {

  case $operatingsystem {
    "Debian": { include dovecot::debian }
    "CentOS": { include dovecot::centos }
  }

}

class dovecot::common {

  service { "dovecot":
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => true,
  }

}

# Squeeze's dovecot expected
class dovecot::debian inherits dovecot::common {
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
      source => [ "puppet:///dist/specific/$fqdn/dovecot.conf", "puppet:///modules/common/dovecot/dovecot_debian.conf" ],
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

class dovecot::centos inherits dovecot::common {
  package { "dovecot":
    ensure => installed,
    require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]],
  }
  Service[dovecot] { require => Package["dovecot"] }
  file {
    "/etc/dovecot.conf":
      mode => 644,
      group => dovecot,
      source => [ "puppet:///dist/specific/$fqdn/dovecot.conf", "puppet:///modules/common/dovecot/dovecot_centos.conf" ],
      notify => Service["dovecot"],
      require => Package["dovecot"];
    "/etc/dovecot-sql.conf":
      # This file contains the database password
      mode => 640,
      group => dovecot,
      content => template("common/dovecot/dovecot-sql.conf.erb"),
      notify => Service["dovecot"],
      require => Package["dovecot"];
  }
}
