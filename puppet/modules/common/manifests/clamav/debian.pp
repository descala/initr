# clamav debian
class common::clamav::debian {

  package {
    ['clamav','clamav-freshclam','clamav-daemon']:
      ensure => installed;
  }

  service {
    ['clamav-daemon','clamav-freshclam']:
      ensure => running,
      enable => true;
  }

  if array_includes($::classes,'mailserver') {
    user {
      'clamav':
        groups     => ['amavis'],
        membership => 'minimum',
        notify     => Service['amavis'],
        require    => Package['amavisd-new'];
    }
  }

}

