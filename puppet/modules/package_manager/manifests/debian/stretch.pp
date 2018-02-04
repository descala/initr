class package_manager::debian::stretch inherits package_manager::debian::common {

  file {
    '/etc/apt/preferences':
      content => template('package_manager/preferences_stretch.erb'),
      notify  => Exec['apt-get update'];
  }

}

