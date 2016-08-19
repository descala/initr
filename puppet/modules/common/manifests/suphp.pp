class common::suphp {
  $suphp_package = $::operatingsystem ? {
    'Debian' => $::lsbmajdistrelease ? {
      '8'     => 'libapache2-mpm-itk',
      default => 'libapache2-mod-suphp'
    },
    'Ubuntu' => 'libapache2-mod-suphp',
    default  => 'mod_suphp'
  }
  package {
    $suphp_package:
      ensure => installed,
      notify => Exec['apache reload'];
  }
  # Debian provided suphp.conf works
  if ( $::operatingsystem == 'Debian' ) or ( $::operatingsystem == 'Ubuntu' ) {
    if ($::operatingsystem == 'Debian' and $::lsbmajdistrelease == '8') {
    common::apache::enmod { 'mpm_itk.load': }
    } else {
    common::apache::enmod { 'suphp.load': }
    common::apache::enmod { 'suphp.conf': }
    }
  } else {
    file {
      '/etc/suphp.conf':
        source => 'puppet:///modules/common/suphp/suphp-redhat.conf';
      '/etc/logrotate.d/suphp':
        source => 'puppet:///modules/common/suphp/logrotate.conf';
    }
  }
}

