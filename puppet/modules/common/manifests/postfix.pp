class common::postfix {

  if array_includes($classes,"nagios::nsca_node") {
    include common::postfix::nagios
  }
  include common::postfix::base
  
  file { '/etc/postfix/main.cf':
    mode => 644,
    owner => root,
    group => root,
    source => [ "puppet:///specific/postfix-main.cf", "puppet:///modules/common/postfix-main-default.cf" ],
    notify => Service['postfix'],
    require => Package['postfix'],
  }

}

