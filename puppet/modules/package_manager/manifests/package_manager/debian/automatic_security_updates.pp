class package_manager::debian::automatic_security_updates {
  file {
    "/etc/cron-apt/action.d/5-install":
      source => "puppet:///modules/package_manager/cron-apt_5-install",
      require => Package["cron-apt"];
  }
  package {
    "cron-apt":
      ensure => installed,
      require => [File["/etc/apt/sources.list"],File["/etc/apt/preferences"]];
  }
}
