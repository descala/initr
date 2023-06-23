# Classe mare de tots els centos

class gnulinux::centos inherits gnulinux {

  include common::ntp

  package { ["redhat-lsb","vixie-cron","crontabs","logrotate","tmpwatch"]:
    ensure => installed,
  }

  # nova organització dels repositoris yum
  include ingent_common::repositorisyum::epel_repo
  include ingent_common::repositorisyum::dagrepo
  include ingent_common::repositorisyum::centos_base_repo

  package { $yum_priorities_plugin:
    ensure => installed,
    require => Package["redhat-lsb"],
  }
  package { $ruby_devel:
    ensure => installed,
  }

  # no hi ha un paquet "ruby-rdoc"

}

