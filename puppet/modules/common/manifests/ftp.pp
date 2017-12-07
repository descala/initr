class common::ftp {

  package { "vsftpd":
    ensure => installed,
  }

  $hasstatus = $operatingsystem ? {
    "Debian" => false,
    default => true
  }
  service { "vsftpd":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => $hasstatus,
    require => Package["vsftpd"],
  }

}

