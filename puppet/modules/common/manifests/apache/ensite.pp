# debian a2ensite
define common::apache::ensite() {
  if $name == "default"
  {
    # WARNING: Debian 8 requires all files in sites-enabled
    # and conf-enabled to end with .conf

    # ensures default is loaded as the first virtualhost
    file { "/etc/apache2/sites-enabled/000-default":
      ensure  => 'link',
      target  => '../sites-available/default',
      require => Package[$httpd],
      notify  => Exec["apache reload"];
    }
  }
  else
  {
    file { "/etc/apache2/sites-enabled/$name":
      ensure  => 'link',
      target  => "../sites-available/$name",
      require => Package[$httpd],
      notify  => Exec["apache reload"];
    }
  }
}

