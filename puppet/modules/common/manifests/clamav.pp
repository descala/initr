class clamav {

  case $operatingsystem {
    "Debian": { include clamav::debian }
    "CentOS": { include clamav::centos }
  }

}

class clamav::debian {

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

class clamav::centos {

  package {
    ["clamav","clamav-update","clamav-db"]:
      require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]],
      ensure => installed;
  }

}
