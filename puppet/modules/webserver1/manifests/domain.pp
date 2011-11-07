#TODO: controlar ensure
define webserver1::domain($username, $password_ftp, $password_db, $password_awstats, $web_backups_server="", $backups_path="", $web_backups_server_port="22", $shell=$nologin, $ensure='present', $database, $force_www='true', $railsapp, $rails_root="", $rails_spawn_method="") {

  if $railsapp == "true" {
    include common::apache::passenger
    webserver1::logrotate_rails { $name:
      rails_root => $rails_root,
      username => $username,
    }
    file {
      "/var/www/$name/htdocs/$rails_root/config/environment.rb": # Rails will be running as this file owner
        owner => $username,
        group => $username;
      "/var/www/$name/htdocs/$rails_root/config/database.yml": # this file contains passwords
        mode => 640;
      "/var/www/$name/htdocs/$rails_root/log/production.log": # log should be writeable by apache
        group => $httpd_user,
        mode => 660;
    }
  }

  webserver1::awstats::domain { $name:
    user => $username,
    pass => $password_awstats,
  }
  webserver1::domain::remotebackup { $name:
    web_backups_server => $web_backups_server,
    backups_path => $backups_path,
  }

  if $database != "" {
    common::mysql::database { $database:
      ensure => present,
      owner => $username,
      passwd => $password_db,
    }
    # removed common::mysql::database::backup, we are doing it in backup.sh.erb now
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
      source => "puppet:///modules/webserver1/vhost.conf",
      replace => false;
  }

  if $operatingsystem == "Debian" {
    common::apache::ensite { "$name.conf":
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

