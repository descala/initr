# signature with postfix
class common::postfix::disclaimer {
  file { "/etc/disclaimer.txt":
    mode => "0644",
    source => "puppet:///specific/disclaimer.txt",
  }
  file { "/etc/disclaimer.html":
    mode => "0644",
    source => "puppet:///specific/disclaimer.html",
  }
  file { "/usr/local/bin/disclaimer.sh":
    mode => "0750",
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
    mode => "0750",
    owner => "filter",
    group => "filter",
  }
  file { "/var/log/disclaimer":
    ensure => present,
    mode => "0644",
    owner => "filter",
  }
}
