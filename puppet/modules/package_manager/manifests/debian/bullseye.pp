# use unattended-upgrades instead of cron-apt
class package_manager::debian::bullseye {

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
      content => '',
      notify  => Exec['apt-get update'];
    '/etc/apt/apt.conf.d/50unattended-upgrades':
      source  => 'puppet:///modules/package_manager/50unattended-upgrades_buster',
      require => Package['unattended-upgrades'];
    # Hetzner installimage leaves a second copy of the security suite in
    # sources.list.d. It duplicates the line in sources.list and, lacking the
    # check-valid-until option, keeps apt-get update failing on its own.
    '/etc/apt/sources.list.d/hetzner-security-updates.list':
      ensure => absent,
      notify => Exec['apt-get update'];
  }

}
