class ftp {

  package { "vsftpd":
    ensure => installed,
  }

  service { "vsftpd":
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus => true,
    require => Package["vsftpd"],
  }

}

class ftp_for_mailserver1 inherits ftp {

  file {
    "/etc/pam.d/vsftpd":
      mode => 600,
      owner => root,
      group => root,
      content => template("mailserver1/pam.d_vsftpd"),
      notify => Service["vsftpd"],
      require => Package["vsftpd"];
#    "/etc/vsftpd/vsftpd.conf":
#    "/etc/vsftpd/buit":
  }

}
