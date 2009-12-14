class webserver1 {

  $phpmyadmindir = $operatingsystem ? {
    Debian => "/usr/share/phpmyadmin",
    default => $lsbdistrelease ? {
      "5.4" => "/usr/share/phpMyAdmin",
      default => "/usr/share/phpmyadmin"
    }
  }
  
  include apache::ssl
  include mysql
  include php
  include webserver1::ftp
  case $operatingsystem {
    "Debian": { include webserver1::awstats::debian }
    "CentOS": {
      case $operatingsystemrelease {
        "5.3": { include webserver1::awstats::centos53 }
        default: { include webserver1::awstats::redhat }
      }
    }
    default: { include webserver1::awstats::redhat }
  }

  Sshkey <<| tag == "backups" |>>

  package {
    ["phpmyadmin",$php_gd]:
      ensure => installed,
      notify => Service[$httpd_service];
    "rsync":
      ensure => installed;
  }

  webserver1::domain { $webserver_domains: }

  package {
    $ruby_shadow:
      ensure => installed;
  }

  cron { "Backup virtualhosts":
    command => "/usr/local/sbin/webserver_backup_all 2>&1 >> /var/log/messages",
    hour => 3,
    minute => 30,
    require => [Package["rsync"],File["/usr/local/sbin/webserver_backup_all"]],
  }

  file {
    "/usr/local/sbin/backup.rb":
      mode => 700,
      source => "puppet:///webserver1/backup.rb";
    "/etc/logrotate.d/$httpd_service":
      mode => 644,
      content => template("webserver1/logrotate_httpd.erb");
    "$phpmyadmindir/config.inc.php":
      mode => 644,
      require => [Package["phpmyadmin"],Package[$httpd]],
      content => template("webserver1/phpmyadmin_config.erb");
    "/usr/local/sbin/webserver_backup_all":
      mode => 700,
      content => template("webserver1/backup_all.sh.erb");
    "/usr/local/sbin/webserver_restore":
      mode => 700,
      content => template("webserver1/restore.sh.erb");
    "/usr/local/sbin/webserver_backup":
      mode => 700,
      content => template("webserver1/backup.sh.erb");
    "/usr/local/sbin/webserver_restore_all":
      mode => 700,
      content => template("webserver1/restore_all.sh.erb");
  }

  # TODO: make this consistent with Debian's ports.conf
  if $operatingsystem == "CentOS" {
    file {
      "$httpd_confdir/vhosts.conf":
        mode => 644,
        source => "puppet:///webserver1/vhosts.conf",
        notify => Service[$httpd_service];
    }
  }

  # redirect to default domain
  ############################

  if $operatingsystem == "Debian" {
    apache::ensite { "default": }
  }
  else
  {
    file {
      "$httpd_sitedir/000-default.conf":
        ensure => "$httpd_sitedir/default",
    }
  }
  
  file {
    "$httpd_sitedir/default":
      content => inline_template('# Puppet managed
<VirtualHost *:80>
RewriteEngine On
RewriteRule ^/(.*) <%=webserver_default_domain%>/$1 [L,R]
</VirtualHost>'),
    notify => Service[$httpd_service],
  }

  
}

#TODO: controlar ensure
define webserver1::domain($username, $password_ftp, $password_db, $password_awstats, $web_backups_server="", $backups_path="", $web_backups_server_port="22", $shell=$nologin, $ensure='present', $database=true, $force_www='true') {

  webserver1::awstats::domain { $name:
    user => $username,
    pass => $password_awstats,
  }
  webserver1::domain::remotebackup { $name:
    web_backups_server => $web_backups_server,
    backups_path => $backups_path,
  }

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
    # removed mysql::database::backup, we are doing it in backup.sh.erb now
  }

  file {
    "/var/www/$name":
      owner => $username,
      group => $username,
      mode => 755,
      ensure => directory,
      require => Package[$httpd];
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
      require => File["/var/www/$name"];
    "/var/www/$name/conf/httpd_include.conf":
      mode => 644,
      notify => Service[$httpd_service],
      require => File["/var/www/$name/conf"],
      content => template("webserver1/httpd_include.conf.erb");
    "$httpd_sitedir/$name.conf":
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

  if $operatingsystem == "Debian" {
    apache::ensite { "$name.conf":
      require => File["$httpd_sitedir/$name.conf"],
    }
  }

  user {
    $username:
      ensure => present,
      comment => "puppet managed",
      home => "/var/www/$name",
      password => $password_ftp,
      shell => $shell,
      require => Package[$ruby_shadow];
  }

}

define webserver1::domain::remotebackup($web_backups_server, $backups_path) {

  $ensure = $web_backups_server ? {
    "" => "absent",
    default => "present"
  }

  Sshkey <<| tag == "${web_backups_server}_backup" |>>

  @@ssh_authorized_key { "backups for $name":
    ensure => $ensure,
    key => $sshdsakey,
    type => "dsa",
    user => $name,
    target => "$backups_path/webservers/$name/.ssh/authorized_keys",
    require => [ File["$backups_path/webservers/$name"], User[$name] ],
    tag => "${web_backups_server}_backup",
  }

  # user to do backups
  @@user { $name:
    ensure => $ensure,
    comment => "puppet managed, backups for $name",
    home => "$backups_path/webservers/$name",
    shell => "/bin/bash", #TODO: allow only scp (http://redmine.ingent.net/issues/show/67)
    tag => "${web_backups_server}_backup",
  }

  # don't remove backups automatically
  if $ensure == "present" {
    @@file { "$backups_path/webservers/$name":
      ensure => directory,
      owner => $name,
      group => $name,
      mode => 750,
      require => [User[$name],File["$backups_path/webservers"]],
      tag => "${web_backups_server}_backup",
    }
  }

}

class webserver1::web_backups_server {

  include sshkeys

  Ssh_authorized_key <<| tag == "$tags_for_sshkey" |>>
  Cron <<| tag == "$tags_for_sshkey" |>>
  User <<| tag == "$tags_for_sshkey" |>>
  File <<| tag == "$tags_for_sshkey" |>>

  file {
    ["/$backups_path","$backups_path/webservers"]:
      ensure => directory;
  }

  # Defaults to 7 days of backup history
  cron { "Purge webserver backups":
    command => "find $backups_path/webservers/* -maxdepth 1 -name \"[0-9][0-9]*-[0-9][0-9]*-[0-9][0-9]*\" -ctime +7 -exec rm -rf {} \;",
    user => root,
    hour => 2,
    minute => 30,
  }

}

class webserver1::ftp inherits ::ftp {

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

class webserver1::awstats {

  package {
    [ "awstats", $perl_net_dns, $perl_net_ip, $perl_geo_ipfree, $perl_net_xwhois ]:
      ensure => installed;
  }

  file {
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
      require => [Exec["create htpasswd"], Package[$httpd]];
    "create htpasswd":
      command => "/bin/touch /etc/awstats/users ; chgrp $httpd_user /etc/awstats/users ; chmod 640 /etc/awstats/users",
      creates => "/etc/awstats/users",
      user => root,
      require => Package["awstats"],
      before => Exec["htpasswd for admin"];
  }

}

class webserver1::awstats::debian inherits webserver1::awstats {
  file {
    "/etc/cron.d/awstats":
      mode => 755,
      content => template("webserver1/awstats_cron.erb"),
      notify => Service[$cron_service];
    "/etc/apache2/conf.d/awstats.conf":
      mode => 644,
      owner => $httpd_user,
      group => $httpd_user,
      content => template("webserver1/awstats_httpd.conf.erb"),
      require => Package[$httpd],
      notify => Service[$httpd_service];
    "/etc/apache2/conf.d/phpmyadmin.conf":
      mode => 640,
      group => $httpd_user,
      require => Package["phpmyadmin"],
      content => template("webserver1/phpmyadmin_httpd.erb");
    "/usr/bin/awstats_updateall.pl":
      mode => 750,
      source => "/usr/share/doc/awstats/examples/awstats_updateall.pl",
      require => Package["awstats"];
  }
  #TODO: install php-mbstring from source?
}

class webserver1::awstats::redhat inherits webserver1::awstats {
  file {
    "/etc/cron.hourly/00awstats":
      mode => 755,
      content => template("webserver1/awstats_cron.erb"),
      notify => Service[$cron_service];
    "/etc/httpd/conf.d/awstats.conf":
      mode => 644,
      content => template("webserver1/awstats_httpd.conf.erb"),
      require => Package[$httpd],
      notify => Service[$httpd_service];
    "/etc/httpd/conf.d/phpmyadmin.conf":
      mode => 640,
      group => $httpd_user,
      require => Package["phpmyadmin"],
      content => template("webserver1/phpmyadmin_httpd.erb");
    "/var/lib/awstats":
      source => "/var/www/awstats",
      recurse => true;
  }
  package {
    "php-mbstring":
      ensure => installed,
      notify => Service[$httpd_service];
  }
}

class webserver1::awstats::centos53 inherits webserver1::awstats::redhat {
  file {
    "/usr/bin/awstats_updateall.pl":
      ensure => "/usr/share/awstats/tools/awstats_updateall.pl",
      require => Package["awstats"];
    "/var/lib/awstats/awstats.pl":
      source => "/usr/share/awstats/wwwroot/cgi-bin/awstats.pl",
      require => Package["awstats"];
  }
}

define webserver1::awstats::domain($user, $pass) {
  
  file {
    "/etc/awstats/awstats.$name.conf":
      require => Package[awstats],
      mode => 644,
      content => template("webserver1/awstats.domain.conf.erb");
  }

  exec { "htpasswd for $user":
    command => "/usr/bin/htpasswd -b /etc/awstats/users $user $pass",
    user => root,
    unless => "grep \"^$user:\" /etc/awstats/users";
  }

}

