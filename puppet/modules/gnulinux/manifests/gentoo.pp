# Classe per a totes les Gentoo
class gnulinux::gentoo inherits gnulinux {

  file { "/etc/portage/package.keywords":
    mode => '0644',
    owner => root,
    group => root,
    source => "puppet:///modules/gnulinux/package.keywords",
  }

  package { ["lsb-release","epm","fcron"]:
    ensure => installed,
  }

  service { "ntpd":
    ensure => running,
    enable => true,
  }

}
