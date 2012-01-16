#TODO: controlar ensure
define webserver1::domain($user_ftp, $user_awstats, $user_mysql, $password_ftp, $password_db, $password_awstats, $web_backups_server="", $backups_path="", $web_backups_server_port="22", $shell=$nologin, $ensure='present', $database, $add_www='true', $force_www='true', $awstats_www='false', $railsapp, $rails_root="", $rails_spawn_method="", $use_suphp='false') {

  if $railsapp == "true" {
    include common::apache::passenger
    webserver1::logrotate_rails { $name:
      rails_root => $rails_root,
      username => $user_ftp,
    }
    file {
      "/var/www/$name/htdocs/$rails_root/config/environment.rb": # Rails will be running as this file owner
        owner => $user_ftp,
        group => $user_ftp;
      "/var/www/$name/htdocs/$rails_root/config/database.yml": # this file contains passwords
        mode => 640;
      "/var/www/$name/htdocs/$rails_root/log/production.log": # log should be writeable by apache
        group => $httpd_user,
        mode => 660;
    }
  }

  if $use_suphp == "true" {
    include common::suphp
  }

  webserver1::awstats::domain { $name:
    user => $user_awstats,
    pass => $password_awstats,
  }
  webserver1::domain::remotebackup { $name:
    web_backups_server => $web_backups_server,
    backups_path => $backups_path,
  }

  if $database != "" {
    common::mysql::database { $database:
      ensure => present,
      owner => $user_mysql,
      passwd => $password_db,
    }
    # removed common::mysql::database::backup, we are doing it in backup.sh.erb now
  }

  file {
    "/var/www/$name":
      owner => $user_ftp,
      group => $httpd_user,
      mode => 750,
      ensure => directory,
      require => Package[$httpd];
    "/var/www/$name/readme.txt":
      group => $user_ftp,
      mode => 750,
      content => template("webserver1/readme.erb"),
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/htdocs":
      owner => $user_ftp,
      group => $user_ftp,
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/logs":
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    ["/var/www/$name/logs/access_log","/var/www/$name/logs/error_log"]:
      mode => 644, #TODO: 644 is too open, but with 640 ftp_user can't read logs
      owner => root,
      group => $httpd_user;
    "/var/www/$name/conf":
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/cgi-bin":
      owner => $user_ftp,
      group => $user_ftp,
      mode => 755,
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/backups":
      mode => 750,
      ensure => directory,
      require => File["/var/www/$name"];
    "/var/www/$name/conf/httpd_include.conf":
      mode => 644,
      notify => Exec["apache reload"],
      require => File["/var/www/$name/conf"],
      content => template("webserver1/httpd_include.conf.erb");
    "$httpd_sitedir/$name.conf":
      notify => Exec["apache reload"],
      ensure => "/var/www/$name/conf/httpd_include.conf";
    "/var/www/$name/conf/vhost.conf":
      mode => 644,
      owner => $user_ftp,
      group => $user_ftp,
      require => File["/var/www/$name/conf"],
      notify => Exec["apache reload"],
      source => "puppet:///modules/webserver1/vhost.conf",
      replace => false;
  }

  if $operatingsystem == "Debian" {
    common::apache::ensite { "$name.conf":
      require => File["$httpd_sitedir/$name.conf"],
    }
  }

  user {
    $user_ftp:
      ensure => present,
      comment => "puppet managed",
      home => "/var/www/$name",
      password => $password_ftp,
      shell => $shell,
      require => Package[$ruby_shadow];
  }

}

