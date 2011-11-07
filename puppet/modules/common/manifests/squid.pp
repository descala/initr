class common::squid {

  package {
    "squid":
      ensure => "present";
  }
  service {
    "squid":
      ensure => "running",
      enable => "true";
  }

}
