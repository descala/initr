# debian a2enmod, but just one symlink
# should be called with file extension (.load or .conf)
# once for each file needed by module
define common::apache::enmod() {
  file { "/etc/apache2/mods-enabled/$name":
    ensure => "../mods-available/$name",
    require => Package[$httpd],
    notify => Exec["apache reload"];
  }
}

