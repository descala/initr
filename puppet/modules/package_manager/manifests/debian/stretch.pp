# on debian stretch use unattended-upgrades instead of cron-apt
class package_manager::debian::stretch {

  include package_manager::debian::sources

  package {
    'cron-apt':
      ensure => purged;
    'unattended-upgrades':
      ensure => installed;
  }
  file {
    '/etc/cron-apt/action.d/5-install':
      ensure => absent;
    '/etc/apt/preferences':
      content => template('package_manager/preferences_stretch.erb'),
      notify  => Exec['apt-get update'];
    '/etc/apt/apt.conf.d/50unattended-upgrades':
      source  => 'puppet:///modules/package_manager/50unattended-upgrades',
      require => Package['unattended-upgrades'];
  }

}
