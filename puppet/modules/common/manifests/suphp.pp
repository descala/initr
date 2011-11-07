class common::suphp {
  $suphp_package = $operatingsystem ? {
    Debian => "libapache2-mod-suphp",
    default => "mod_suphp"
  }
  package {
    $suphp_package:
      ensure => installed,
      notify => Service[$httpd_service];
  }
}

