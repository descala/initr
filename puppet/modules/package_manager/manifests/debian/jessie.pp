class package_manager::debian::jessie inherits package_manager::debian::common {

  file {
    '/etc/apt/preferences':
      content => template('package_manager/preferences_jessie.erb'),
      notify  => Exec['apt-get update'];
  }

}

