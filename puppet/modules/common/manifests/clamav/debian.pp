class common::clamav::debian {

  package {
    ["clamav","clamav-freshclam","clamav-daemon"]:
      ensure => installed;
  }

  service {
    ["clamav-daemon","clamav-freshclam"]:
      enable => true,
      ensure => running;
  }

  if array_includes($classes,'common::amavis::common') {
    user {
      "clamav":
        groups     => ['amavis'],
        membership => 'minimum',
        require => Package['amavisd-new'];
    }
  }

}

