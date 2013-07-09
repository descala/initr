class common::dovecot::centos inherits common::dovecot::common {
  package { "dovecot":
    ensure => installed,
    require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]],
  }
  Service[dovecot] { require => Package["dovecot"] }
  file {
    "/etc/dovecot.conf":
      mode => 644,
      group => dovecot,
      source => "puppet:///modules/common/dovecot/dovecot_centos.conf",
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
