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
  include ftp
  include webserver1::awstats
  case $operatingsystem {
    "Debian": { include webserver1::awstats::debian }
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
    "$phpmyadmindir/config.inc.php":
      mode => 644,
      require => [Package["phpmyadmin"],Package[$httpd]],
      content => template("webserver1/phpmyadmin_config.erb");
  }

}

#TODO: controlar ensure
define webserver1::domain($username, $password_ftp, $password_db, $password_awstats, $web_backups_server="", $backups_path="/var/backups", $web_backups_server_port="22", $shell='/sbin/nologin', $ensure='present', $database=true, $force_www='true') {

  webserver1::awstats::domain { $name:
    user => $username,
    pass => $password_awstats,
  }
  webserver1::domain::remotebackup { $name:
    web_backups_server => $web_backups_server,
    port => $web_backups_server_port,
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

  if $operatingsystem == "Debian" {
    apache::ensite { "$name.conf":
      require => File["$httpd_confdir/$name.conf"],
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

define webserver1::domain::remotebackup($web_backups_server, $backups_path, $port, $hour="3", $min="30", $history=7, $excludes="") {

  $ensure = $web_backups_server ? {
    "" => "absent",
    default => "present"
  }

  Sshkey <<| tag == "${web_backups_server}_backup" |>>

  cron { "Backup $name":
    ensure => $ensure,
    command => "/usr/local/sbin/backup.rb $name $web_backups_server $port $history $excludes 2>&1 >> /var/log/messages",
    user => root,
    hour => $hour,
    minute => $min,
    require => Package["rsync"],
  }

  @@ssh_authorized_key { "backups for $name":
    ensure => $ensure,
    key => $sshdsakey,
    type => "dsa",
    user => $name,
    target => "$backups_path/webservers/$name/.ssh/authorized_keys",
    require => [ File["$backups_path/webservers/$name"], User[$name] ],
    tag => "${web_backups_server}_backup",
  }

  $prevhour = $hour - 1
  @@cron { "Purge $name":
    ensure => $ensure,
    command => "find $backups_path/webservers/$name -maxdepth 1 -name \"[0-9][0-9]*-[0-9][0-9]*-[0-9][0-9]*\" -ctime +$history -delete",
    user => root,
    hour => $prevhour,
    minute => $min,
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
      mode => 755,
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
    [$backups_path,"$backups_path/webservers"]:
      ensure => directory;
  }
}

class webserver1::awstats {

  package {
    [ "awstats", $perl_net_dns, $perl_net_ip, $perl_geo_ipfree, $perl_net_xwhois ]:
      ensure => installed;
  }

  file {
    "/etc/cron.hourly/awstats":
      mode => 755,
      source => "puppet:///webserver1/awstats_cron",
      notify => Service[$cron_service];
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

class webserver1::awstats::debian {
  file {
    "/etc/apache2/conf.d/awstats.conf":
      mode => 644,
      source => "puppet:///webserver1/awstats_httpd.conf",
      require => Package[$httpd],
      notify => Service[$httpd_service];
    "/etc/apache2/conf.d/phpmyadmin.conf":
      mode => 640,
      group => $httpd_user,
      require => Package["phpmyadmin"],
      content => template("webserver1/phpmyadmin_httpd.erb");
  }
  #TODO: install php-mbstring from source?
}

class webserver1::awstats::redhat {
  file {
    "/etc/httpd/conf.d/awstats.conf":
      mode => 644,
      source => "puppet:///webserver1/awstats_httpd.conf",
      require => Package[$httpd],
      notify => Service[$httpd_service];
    "/etc/httpd/conf.d/phpmyadmin.conf":
      mode => 640,
      group => $httpd_user,
      require => Package["phpmyadmin"],
      content => template("webserver1/phpmyadmin_httpd.erb");
  }
  package {
    "php-mbstring":
      ensure => installed,
      notify => Service[$httpd_service];
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


