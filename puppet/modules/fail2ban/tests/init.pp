class { "fail2ban":
  mailto => "alert@example.com",
  jails => ["vsftpd", "ssh"],
}
