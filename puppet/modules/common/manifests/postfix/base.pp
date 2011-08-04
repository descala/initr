class common::postfix::base {
  include common::rm_sendmail
  file { "/etc/alternatives/mta":
    ensure => "/usr/sbin/sendmail.postfix",
  }
  package {
    ["postfix","pfqueue"]:
      ensure => installed;
  }
  exec {
    "/usr/sbin/postalias /etc/aliases":
      creates => '/etc/aliases.db',
      require => Package["postfix"],
  }
  service {
    "postfix":
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => Package['sendmail','postfix'];
  }
}

