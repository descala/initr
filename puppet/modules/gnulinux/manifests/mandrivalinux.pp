# Classe mare de tots els Mandriva / Mandrake
class gnulinux::mandrivalinux inherits gnulinux {

  include common::ntp

  # en mandriva el ruby esta instal·lat del codi font
  # el definim perque no el trobi a faltar la calsse rubygems
  Package[$ruby] { ensure => absent, }
  package{$rdoc: ensure => absent, }
  package{$ruby_devel: ensure => absent, }

  # Enllaç cap al ruby
  # si no, el cron no executa el ruby
  # i en concret el ssh_station_watch no va
  file { "/usr/bin/ruby":
    ensure => "/usr/local/bin/ruby",
  }

}

