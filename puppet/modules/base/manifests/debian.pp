# Class: debian
#
# Class for all Debian distributions.
class debian inherits gnulinux {

#  include arxiver
#  include puppet::client
#  include ntp
  
  package { "lsb-release":
  	ensure => present,
  }
  package { $ruby_devel:
    ensure => installed,
  }
  package { $rdoc:
    ensure => installed,
    require => Package[$ruby],
  }
}

class debian5_0 inherits debian {
  file { "/etc/apt/sources.list":
    owner => root,
    group => root,
    mode => 644,
    source => [ "puppet:///dist/specific/$fqdn/sources.list", "puppet:///base/sources.list" ];
  }
  file { "/etc/apt/preferences":
    owner => root,
    group => root,
    mode => 644,
    source => [ "puppet:///dist/specific/$fqdn/apt_preferences", "puppet:///base/apt_preferences" ];
  }
}
