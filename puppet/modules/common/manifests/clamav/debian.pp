class common::clamav::debian {

  package {
    ["clamav","clamav-freshclam"]:
      ensure => installed;
  }

  service {
    "clamav-daemon":
      enable => false,
      ensure => stopped;
    "clamav-freshclam":
      enable => true,
      ensure => running;
  }

}

