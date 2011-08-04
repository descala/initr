class webserver1::ftp inherits common::ftp {

  # user shell should appear on /etc/shells to allow ftp login
  append_if_no_such_line { nologin_shell:
    file => "/etc/shells",
    line => "$nologin",
    before => File[$vsftpd_conf_file],
  }

  file { $vsftpd_conf_file:
    content => template("webserver1/vsftpd.conf.erb"),
    require => Package["vsftpd"],
    notify => Service["vsftpd"]
  }

}

