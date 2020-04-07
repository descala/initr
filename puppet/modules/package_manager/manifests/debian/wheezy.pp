# package manager Wheezy
class package_manager::debian::wheezy inherits package_manager::debian::common {

  file {
    '/etc/apt/preferences':
      content => template('package_manager/preferences_wheezy.erb'),
      notify  => Exec['apt-get update'];
    '/etc/apt/apt.conf.d/10no--check-valid-until':
      content => 'Acquire::Check-Valid-Until "0";',
      notify  => Exec['apt-get update'];
  }

}

