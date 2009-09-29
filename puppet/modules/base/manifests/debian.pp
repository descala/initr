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
  exec { "apt-get update":
    refreshonly => true,
  }
}

class debian5_0 inherits debian {
  
  # Do not forget to run apt-get update after modifying the /etc/apt/sources.list file.
  # You must do this to let APT obtain the package lists from the sources you specified.
  file { "/etc/apt/sources.list":
    owner => root,
    group => root,
    mode => 644,
    notify => Exec["apt-get update"],
    source => [ "puppet:///dist/specific/$fqdn/sources.list", "puppet:///base/sources.list" ];
  }
  file { "/etc/apt/preferences":
    owner => root,
    group => root,
    mode => 644,
    notify => Exec["apt-get update"],
    source => [ "puppet:///dist/specific/$fqdn/apt_preferences", "puppet:///base/apt_preferences" ];
  }

}

# alias
class debian5_0_1 {
  include debian5_0
}
class debian5_0_2 {
  include debian5_0
}
class debian5_0_3 {
  include debian5_0
}
