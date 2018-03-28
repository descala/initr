class ftp_server {

  include common::ftp

  file {
    $vsftpd_conf_file:
      notify => Service["vsftpd"],
      content => template("ftp_server/vsftpd.conf.erb");
    "/etc/vsftpd.user_list":
      notify => Service["vsftpd"],
      content => template("ftp_server/vsftpd.user_list.erb");
    "/usr/local/sbin/clean_ftpusers.sh":
      mode => '0700', owner => root, group => root,
      source => "puppet:///modules/ftp_server/clean_ftpusers.sh";
    "/home/ftpusers":
      source => "puppet:///modules/ftp_server/empty",
      recurse => true,
      recurselimit => 1,
      purge => true,
      notify => Exec["/usr/local/sbin/clean_ftpusers.sh"],
      backup => false,
      force => true,
      ignore => [".gitignore"];
  }

  append_if_no_such_line {
    nologin_shell:
      file => "/etc/shells",
      line => "/usr/sbin/nologin";
  }

  exec {
    "/usr/local/sbin/clean_ftpusers.sh":
      user => root,
      require => File["/usr/local/sbin/clean_ftpusers.sh"],
      refreshonly => true;
  }

  create_resources(ftp_server::user, $ftp_users)

}

