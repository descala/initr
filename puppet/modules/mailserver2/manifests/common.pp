class mailserver2::common {

  $db_name="postfix"           # database name
  $db_user="postfix"           # database user
  $db_passwd="postfixadmin"    # database user password
  $db_passwd_encrypt="cleartext" # md5crypt | md5 | system | cleartext
  $db_passwd_encrypt_httpd="none" # none | crypt | scrambled | md5 | aes | sha1
# sense PAM
#  $db_passwd_encrypt_pam="0" # md5crypt=, md5=3, system=, cleartext=0
#
  $imap_passwd="itest"      # imap administrator password
  $bak_host="one.ingent.net" # host to backup database dumps ( coment "maildb-scp" cron definitions if don't want that )

  # where postfix messages should be sent
  if $mailserver2_admin_email {
    $admin_email = $mailserver2_admin_email
  } else {
    $admin_email = "admin@ingent.net"
  }
  # where mail will be stored
  if $mailserver2_mail_location {
    $mail_location = $mailserver2_mail_location
  } else {
    $mail_location = "/var/mail/virtual"
  }
  if !($domain_in_mailbox) {
    $domain_in_mailbox =  "1"
  }
  if !($domain_path) {
    $domain_path = "0"
  }


  include common::apache
  include common::php
  include common::mysql
  include common::clamav
  class { "common::amavis":
    db_name => $db_name,
    db_user => $db_user,
    db_passwd => $db_passwd,
  }
  class { "common::dovecot":
    db_name => $db_name,
    db_user => $db_user,
    db_passwd => $db_passwd,
    db_passwd_encrypt => $db_passwd_encrypt,
    mail_location => $mail_location,
    admin_mail => $admin_email,
  }
  class { "common::postfixadmin":
    db_name => $db_name,
    db_user => $db_user,
    db_passwd => $db_passwd,
    postfixadmin_user => "admin@localhost.loc",
    postfixadmin_passwd => "changeme",
    admin_email => $admin_email,
    db_passwd_encrypt => $db_passwd_encrypt,
    bak_host => $bak_host,
    domain_in_mailbox => $domain_in_mailbox,
    domain_path => $domain_path,
  }

  if array_includes($classes,"nagios::nsca_node") {
    include mailserver2::nagios
  }

  package {
    ["squirrelmail","pfqueue","spamassassin","postfix","postgrey"]:
      ensure => installed;
    ["sendmail","exim"]:
      ensure => absent;
  }

  user {
    "vmail":
      ensure => present,
      comment => "Virtual mailbox (Puppet managed)",
      uid => 201,
      gid => mail,
      home => $mail_location,
      shell => "/sbin/nologin";
  }  
  
  service { 
    ["postfix","postgrey"]:
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => Package["postfix"];
    "spamassassin":
      enable => false,
      ensure => stopped, # spamassassin runs through amavisd
      hasstatus => true,
      require => Package["spamassassin"];
  }

  file {
    $mail_location:
      ensure => directory,
      mode => '0770',
      owner => vmail,
      group => mail,      
      require => User["vmail"];
    "/etc/postfix/aliases.pcre":
      mode    => '0644',
      replace => no,
      source  => 'puppet:///modules/mailserver2/aliases.pcre',
      require => Package["postfix"];
    "/etc/postfix/mysql-virtual-aliases.cf":
      mode => '0640',
      group => postfix,
      content => template("mailserver2/mysql-virtual-aliases.cf.erb"),
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/mysql-virtual-alias-domains.cf":
      mode => '0640',
      group => postfix,
      content => template("mailserver2/mysql-virtual-alias-domains.cf.erb"),
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/mysql-virtual-aliases-postmaster.cf":
      mode => '0640',
      group => postfix,
      content => template("mailserver2/mysql-virtual-aliases-postmaster.cf.erb"),
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/mysql-virtual-domains.cf":
      mode => '0640',
      group => postfix,
      content => template("mailserver2/mysql-virtual-domains.cf.erb"),
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/mysql-virtual-mailbox.cf":
      mode => '0640',
      group => postfix,
      content => template("mailserver2/mysql-virtual-mailbox.cf.erb"),
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/mysql-virtual-alias-domains-mailbox.cf":
      mode => '0640',
      group => postfix,
      content => template("mailserver2/mysql-virtual-alias-domains-mailbox.cf.erb"),
      notify => Service["postfix"],
      require => Package["postfix"];
    "/etc/postfix/recipient_access":
      mode => '0644',
      source => [ "puppet:///specific/recipient_access", "puppet:///modules/mailserver2/recipient_access" ],
      notify => Exec["postmap_ra"],
      require => Package["postfix"];
    "/etc/postfix/recipient_greylist":
      mode => '0644',
      source => [ "puppet:///specific/recipient_st", "puppet:///modules/mailserver2/recipient_greylist" ],
      notify => Exec["postmap_rg"],
      require => Package["postfix"];
    "/etc/postfix/recipient_bcc":
      mode => '0644',
      replace => false,
      source => [ "puppet:///modules/mailserver2/recipient_bcc" ],
      notify => Exec["postmap_bcc"],
      require => Package["postfix"];
    "/etc/postfix/sender_bcc":
      mode => '0644',
      replace => false,
      source => [ "puppet:///modules/mailserver2/sender_bcc" ],
      notify => Exec["postmap_bcc"],
      require => Package["postfix"];
    "/etc/squirrelmail/config_local.php":
      mode => '0640',
      group => $httpd_user,
      source => [ "puppet:///specific/squirrelmail.conf.php", "puppet:///modules/mailserver2/squirrelmail.conf" ],
      require => Package["squirrelmail"];
    "/etc/aliases":
      notify => Exec["/usr/sbin/postalias /etc/aliases"];
    "/etc/mail/spamassassin/sasl_authenticated.cf":
      mode => '0644',
      content => template("mailserver2/sasl_authenticated.cf.erb"),
      require => Package["spamassassin"],
      notify => Service["amavis"];
    "/etc/mail/spamassassin/90_puppet_custom_rules.cf":
      mode => '0644',
      source => [ "puppet:///modules/mailserver2/90_puppet_custom_rules.cf" ],
      require => Package["spamassassin"],
      notify => Service["amavis"];
    "/etc/mail/spamassassin/90_clamav_scores.cf":
      mode => '0644',
      source => [ "puppet:///modules/mailserver2/90_clamav_scores.cf" ],
      require => Package["spamassassin"],
      notify => Service["amavis"];
    }

  exec {
    "/usr/sbin/postalias /etc/aliases":
      creates => '/etc/aliases.db',
      require => Package["postfix"];
    "/usr/sbin/postmap /etc/postfix/aliases.pcre":
      subscribe => File["/etc/postfix/aliases.pcre"],
      refreshonly => true,
      notify => Service["postfix"];
    "/usr/bin/gpasswd -a clamav amavis":
      require => [Package["amavisd-new"],Package["clamav"]],
      notify => Service["amavis"],
      onlyif => "test -z \"`groups clamav |grep amavis`\"";
    "/usr/sbin/postmap /etc/postfix/recipient_access":
      alias => "postmap_ra",
      refreshonly => true,
      require => Package["postfix"];
    "/usr/sbin/postmap /etc/postfix/recipient_greylist":
      alias => "postmap_rg",
      refreshonly => true,
      require => Package["postfix"];
    "/usr/sbin/postmap /etc/postfix/recipient_bcc /etc/postfix/sender_bcc":
      alias => "postmap_bcc",
      refreshonly => true,
      require => Package["postfix"];
  }

  cron {
    "maildb-bak":
      command => "mysqldump $db_name > /root/maildb-bak.sql",
      user => root,
      hour => 3,
      minute => 0,
      require => Service[$mysqld];
    "maildb-scp":
      command => "/usr/bin/scp /root/maildb-bak.sql backup_$hostname@$bak_host:/var/arxiver/backups/backup_$hostname/backup_mail_$hostname/",
      user => root,
      hour => 3,
      minute => 15,
      require => Cron["maildb-bak"];
  }

  append_if_no_such_line { httpd_virtualhosts:
    file => $httpd_conffile,
    line => "NameVirtualHost *:80",
    require => Package[$httpd],
    notify => Service[$httpd],
  }

}
