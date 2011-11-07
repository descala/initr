class common::suphp {
  $suphp_package = $operatingsystem ? {
    /Debian|Ubuntu/ => "libapache2-mod-suphp",
    default => "mod_suphp"
  }
  package {
    $suphp_package:
      ensure => installed,
      notify => Service[$httpd_service];
  }
  # Debian provided suphp.conf works
  if ( $operatingsystem == 'Debian' ) or ( $operatingsystem != 'Ubuntu' ) {
    common::apache::enmod { "suphp": }
  } else {
    file {
      "/etc/suphp.conf":
        source => "puppet:///modules/common/suphp/suphp-redhat.conf";
    }
  }
}

