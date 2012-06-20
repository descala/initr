# debian a2dissite
define common::apache::dissite() {
  file { ["/etc/apache2/sites-enabled/$name","/etc/apache2/sites-enabled/000-$name"]:
    ensure => absent,
    require => Package[$httpd],
    notify => Exec["apache reload"];
  }
}

