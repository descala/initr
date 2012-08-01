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

}

