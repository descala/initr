class webserver1 {
  
  include apache::ssl
  include mysql
  include php
  include ftp
  include webserver1::awstats

  Sshkey <<| tag == "backups" |>>

  package {
    ["phpmyadmin","php-mbstring","php-gd"]:
      ensure => installed,
      notify => Service[$httpd_service];
    "rsync":
      ensure => installed;
  }

  webserver1::domain { $webserver_domains: }
  bind::masterzone  { $bind_masterzones: }

  package {
    "ruby-shadow":
      ensure => installed;
  }

  file {
    # vhosts.conf (abans template) ara nomes te: NameVirtualHost *:80
    "$httpd_confdir/vhosts.conf":
      mode => 644,
      source => "puppet:///webserver1/vhosts.conf",
      notify => Service[$httpd_service];
    "/usr/local/sbin/backup.rb":
      mode => 700,
      source => "puppet:///webserver1/backup.rb";
    "/etc/logrotate.d/httpd":
      mode => 644,
      source => "puppet:///webserver1/logrotate_httpd";
    "/etc/httpd/conf.d/phpmyadmin.conf":
      mode => 640,
      group => apache,
      require => Package["phpmyadmin"],
      content => template("webserver1/phpmyadmin_httpd.erb");
    "/usr/share/phpmyadmin/config.inc.php":
      mode => 644,
      require => [Package["phpmyadmin"],Package[$httpd]],
      content => template("webserver1/phpmyadmin_config.erb");
  }

}

#TODO: controlar ensure
define webserver1::domain($username, $password_ftp, $password_db, $password_awstats, $backup_server, $shell='/sbin/nologin', $ensure='present', $database=true, $force_www='true') {

  webserver1::awstats::domain { $name:
    user => $username,
    pass => $password_awstats,
  }
  webserver1::domain::remotebackup { $name: }

  case $database {
    false: {}
    true: {
      $dbname=gsub($name,'[\.-]','')
    }
    default: {
      $dbname = $database
    }
  }

  if $database {
    mysql::database { $dbname:
      ensure => present,
      owner => $username,
      passwd => $password_db,
    }
    mysql::database::backup { $dbname:
      destdir => "/var/www/$name/backups",
      user => $username,
      pass => $password_db,
    }
  }


  file {
    "/var/www/$name":
      owner => $username,
      group => $username,
      mode => 755,
      ensure => directory;
    "/var/www/$name/readme.txt":
      group => $username,
      mode => 750,
      content => template("webserver1/readme.erb"),
      require => [File["/var/www/$name"],User[$username]];
    "/var/www/$name/htdocs":
      owner => $username,
      group => $username,
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$username]];
    "/var/www/$name/logs":
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$username]];
    "/var/www/$name/conf":
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$username]];
    "/var/www/$name/cgi-bin":
      owner => $username,
      group => $username,
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$username]];
    "/var/www/$name/backups":
      mode => 750,
      ensure => directory,
      require => [File["/var/www/$name"],User[$username]];
    "/var/www/$name/conf/httpd_include.conf":
      mode => 644,
      notify => Service[$httpd_service],
      require => File["/var/www/$name/conf"],
      content => template("webserver1/httpd_include.conf.erb");
    "$httpd_confdir/$name.conf":
      notify => Service[$httpd_service],
      ensure => "/var/www/$name/conf/httpd_include.conf";
    "/var/www/$name/conf/vhost.conf":
      mode => 644,
      owner => $username,
      group => $username,
      require => File["/var/www/$name/conf"],
      notify => Service[$httpd_service],
      source => "puppet:///webserver1/vhost.conf",
      replace => false;
  }

  user {
    $username:
      ensure => present,
      comment => "puppet managed",
      home => "/var/www/$name",
      password => $password_ftp,
      shell => $shell,
      require => Package["ruby-shadow"];
  }

}

define webserver1::domain::remotebackup($hour="3", $min="30", $server="arxiver006.arxiver.com", $history=7, $excludes="") {
  @@ssh_authorized_key { "backups for $name":
    ensure => present,
    key => $sshdsakey,
    type => "dsa",
    tag => "backups",
    user => $name,
    target => "/var/arxiver/webservers/$name/.ssh/authorized_keys",
    require => [ File["/var/arxiver/webservers/$name"], User[$name] ],
  }

  cron { "Backup $name":
    command => "/usr/local/sbin/backup.rb $name $server $history $excludes 2>&1 >> /var/log/messages",
    user => root,
    hour => $hour,
    minute => $min,
    require => Package["rsync"],
  }

  # usuari per les copies de seguretat
  @@user { $name:
    ensure => present,
    comment => "puppet managed, backups for $name",
    home => "/var/arxiver/webservers/$name",
    shell => "/bin/bash", #TODO: nomes scp (http://redmine.ingent.net/issues/show/67)
    tag => "backups",
  }

  @@file { "/var/arxiver/webservers/$name":
    ensure => directory,
    owner => $name,
    group => $name,
    mode => 755,
    require => [ User[$name], File["/var/arxiver/webservers"] ],
    tag => "backups",
  }

}

class webserver1::backups_server {

  Ssh_authorized_key <<| tag == "backups" |>>
  User <<| tag == "backups" |>>
  File <<| tag == "backups" |>>

  file { "/var/arxiver/webservers":
    ensure => directory,
  }

  @@sshkey { $fqdn:
    ensure => present,
    key => $sshrsakey,
    type => "rsa",
    tag => "backups",
  }
}

class webserver1::awstats {

  package {
    [ "awstats", "perl-Net-DNS", "perl-Net-IP", "perl-Geo-IPfree", "perl-Net-XWhois" ]:
      ensure => installed;
  }

  file {
    "/etc/cron.hourly/awstats":
      mode => 755,
      source => "puppet:///webserver1/awstats_cron",
      notify => Service[$cron_service];
    "/etc/httpd/conf.d/awstats.conf":
      mode => 644,
      source => "puppet:///webserver1/awstats_httpd.conf",
      require => Package[$httpd],
      notify => Service[$httpd_service];
    "/etc/awstats/awstats.model.conf":
      mode => 644,
      require => Package["awstats"],
      source => "puppet:///webserver1/awstats.model.conf";
  }

  exec {
    "htpasswd for admin":
      command => "/usr/bin/htpasswd -b /etc/awstats/users admin $admin_password",
      user => root,
      unless => "grep \"^admin:\" /etc/awstats/users",
      require => Exec["create htpasswd"];
    "create htpasswd":
      command => "/bin/touch /etc/awstats/users",
      creates => "/etc/awstats/users",
      user => root,
      require => Package["awstats"],
      before => Exec["htpasswd for admin"];
  }


}

define webserver1::awstats::domain($user, $pass) {
  
  file {
    "/etc/awstats/awstats.$name.conf":
      mode => 644,
      content => template("webserver1/awstats.domain.conf.erb");
  }

  exec { "htpasswd for $user":
    command => "/usr/bin/htpasswd -b /etc/awstats/users $user $pass",
    user => root,
    unless => "grep \"^$user:\" /etc/awstats/users";
  }

}


