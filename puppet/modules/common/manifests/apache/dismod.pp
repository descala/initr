# debian a2dismod
define common::apache::dismod() {
  file { ["/etc/apache2/mods-enabled/${name}.conf","/etc/apache2/mods-enabled/${name}.load"]:
    ensure => absent,
    require => Package[$httpd],
    notify => Exec["apache reload"];
  }
}

