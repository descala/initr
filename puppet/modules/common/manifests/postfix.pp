class postfix {

  if array_includes($classes,"nagios::nsca_node") {
    include postfix::nagios
  }
  include postfix::base
  
  file { '/etc/postfix/main.cf':
    mode => 644,
    owner => root,
    group => root,
    source => [ "puppet:///specific/postfix-main.cf", "puppet:///modules/common/postfix-main-default.cf" ],
    notify => Service['postfix'],
    require => Package['postfix'],
  }

}

class postfix::base {
  include rm_sendmail
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

class postfix::centosplus inherits postfix::base {
  Package["postfix"] { require => File["/etc/yum.repos.d/CentOS-Base.repo"] }
}

class postfix::nagios {
  nagios::check { "smtp":
    command => "check_smtp -H localhost -w 10 -c 20 -t 30",
  }
  # Usage: check_mailq -w <warn> -c <crit> [-W <warn>] [-C <crit>] [-M <MTA>] [-t <timeout>] [-v verbose]
  # Checks the number of messages in the mail queue
  if $mailq_warn {
    $mqw=$mailq_warn
  } else {
    $mqw=100
  }
  nagios::check { "check_mailq":
    command => "check_mailq -w $mqw -c 1000 -t 30 -M postfix",
  }
  if $skip_blacklist_check {
  } else {
    include nagios::check_blacklisted
  }
}

class spamassassin {
  package { "spamassassin":
    ensure => installed,
  }
}

# signatures amb el postfix
# faltaria configurar el postfix (veure specific del 032)
class disclaimer {
  file { "/etc/disclaimer.txt":
    mode => 644,
    source => "puppet:///specific/disclaimer.txt",
  }
  file { "/etc/disclaimer.html":
    mode => 644,
    source => "puppet:///specific/disclaimer.html",
  }
  file { "/usr/local/bin/disclaimer.sh":
    mode => 750,
    owner => "filter",
    source => "puppet:///specific/disclaimer.sh",
  }
  user { "filter":
    comment => "Postfix Filters",
    ensure => present,
    home => "/var/spool/filter",
    shell => "/sbin/nologin"
  }
  file { "/var/spool/filter":
    ensure => directory,
    mode => 750,
    owner => "filter",
    group => "filter",
  }
  file { "/var/log/disclaimer":
    ensure => present,
    mode => 644,
    owner => "filter",
  }
}
