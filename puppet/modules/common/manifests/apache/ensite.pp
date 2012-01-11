# debian a2ensite
define common::apache::ensite() {
  if $name == "default"
  {
    # ensures default is loaded as the first virtualhost
    file { "/etc/apache2/sites-enabled/000-default":
      ensure => "../sites-available/default",
      require => Package[$httpd],
      notify => Exec["apache reload"];
    }
  }
  else
  {
    file { "/etc/apache2/sites-enabled/$name":
      ensure => "../sites-available/$name",
      require => Package[$httpd],
      notify => Exec["apache reload"];
    }
  }
}

