# Classe mare de tots els Fedora Core
class gnulinux::fedoracore inherits gnulinux {

#  include arxiver
#  include puppet::client
#  include common::ntp
#
#  package { $ruby_devel:
#    ensure => installed,
#  }
#  package { $rdoc:
#    ensure => installed,
#    require => Package[$ruby],
#  }

  include ingent_common::repositorisyum::fedora_core_repos

}
