class common::clamav::centos {

  package {
    ["clamav","clamav-update","clamav-db"]:
      require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]],
      ensure => installed;
  }

}
