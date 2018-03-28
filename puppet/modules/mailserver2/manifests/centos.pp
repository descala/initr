class mailserver2::centos inherits mailserver2::common {
  Exec["/usr/bin/gpasswd -a clamav amavis"] { notify +> Service["clamd"] }
  # Do after configuring centos plus, needed to get postfix .el5.centos.mysql_pgsql
  Package["squirrelmail"] { require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]] }
  Package["pfqueue"]      { require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]] }
  Package["spamassassin"] { require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]] }
  Package["postfix"]      { require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]] }
  Package["postgrey"]     { require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]] }
  Service["postgrey"] { hasstatus => false, pattern => "postgrey" } # status returns 0 even if stopped
  package {
    ["php-mbstring","php-imap"]:
      ensure => installed,
      require => Package["rpmforge-release"],
      notify => Service[$httpd_service];
    "perl-GD-Graph3d":
      ensure => installed,
      require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]];
  }
  service {
    "saslauthd":
      enable => false,
      ensure => stopped,
      hasrestart => true,
      hasstatus => true;
  }
  file {
    "/etc/postfix/local.domains":
      ensure => absent;
    "/etc/alternatives/mta":
      ensure => "/usr/sbin/sendmail.postfix";
    "/etc/postfix/master.cf":
      mode => '0644',
      source => [ "puppet:///specific/postfix-master.cf", "puppet:///modules/mailserver2/master_centos.cf" ],
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/main.cf":
      mode => '0644',
      source => [ "puppet:///specific/postfix-main.cf", "puppet:///modules/mailserver2/main_centos.cf" ],
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/my.cnf":
      mode => '0644',
      source => [ "puppet:///specific/my.cnf", "puppet:///modules/mailserver2/my.cnf" ],
      require => Package["mysql-server"],
      notify => Service[$mysqld];
    # Fixes SA update cron to restart amavisd instead of spamassassin
    "/usr/share/spamassassin/sa-update.cron":
      mode => '0744',
      source => "puppet:///modules/mailserver2/sa-update.cron",
      require => Package["spamassassin"];
    "/etc/sysconfig/freshclam":
      ensure => absent;
    "/etc/freshclam.conf":
      source => "puppet:///modules/mailserver2/freshclam.conf";
  }
  cron {
    # Update SA rules once a day
    "sa-update":
      command =>"/usr/share/spamassassin/sa-update.cron 2>&1 | tee -a /var/log/sa-update.log",
      user => root,
      hour => 4, minute => 30;
  }
}

