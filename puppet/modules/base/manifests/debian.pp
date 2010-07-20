# Class: debian
#
# Class for all Debian distributions.
class debian inherits gnulinux {

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
