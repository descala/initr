class nagios::ssl_cert {
  file {
    "$nagios_plugins_dir/check_ssl_cert":
      mode => 755,
      source => "puppet:///modules/nagios/check_ssl_cert";
  }
  package {
    $ca_certificates:
      ensure => installed;
  }
}

