class common::amavis::centos inherits common::amavis::common {
  Package["amavisd-new"] { require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]] }

  service {
    "amavisd":
      alias => "amavis",
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => false,
      pattern => "amavisd",
      require => Package["amavisd-new"];
    "clamd":
      name => "clamd.amavisd",
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => Package["amavisd-new"];
  }

  file {
    "/etc/amavisd/amavisd.conf":
      mode => 644,
      content => template("common/amavis/amavisd.conf.erb"),
      require => Package["amavisd-new"],
      notify => Service["amavisd"];
    "/etc/sysconfig/clamd.amavisd":
      source => "puppet:///modules/common/amavis/sysconfig_clamd.amavisd",
      notify => Service["clamd"];
    "/etc/clamd.d/amavisd.conf":
      mode => 644,
      source => "puppet:///modules/common/amavis/clamd_amavisd.conf",
      require => Package["clamav"],
      notify => Service["clamd"];
  }

}


