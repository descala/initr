#TODO: controlar ensure
define webserver1::domain($user_ftp, $user_awstats, $user_mysql, $password_ftp, $password_db, $password_awstats, $web_backups_server="", $backups_path="", $web_backups_server_port="22", $shell=$nologin, $ensure='present', $database, $add_www='true', $force_www='true', $awstats_www='false', $railsapp, $rails_root="", $rails_spawn_method="", $use_suphp='false', $allow_override='None') {

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
        mode => '0640';
      "/var/www/$name/htdocs/$rails_root/log/production.log": # log should be writeable by apache
        group => $httpd_user,
        mode => '0660';
    }
  }

  if $use_suphp == "true" {
    include common::suphp
  }

  webserver1::awstats::domain { $name:
    user        => $user_awstats,
    pass        => $password_awstats,
    awstats_www => $awstats_www
  }

  #TODO: create a config file to avoid having to pass too many parameters to backup.rb
  webserver1::domain::remotebackup { $name:
    web_backups_server => $web_backups_server,
    backups_path => $backups_path,
    user_ftp => $user_ftp,
  }

  if $database != "" {
    common::mysql::database { $database:
      ensure => present,
      owner => $user_mysql,
      passwd => $password_db,
    }
    # removed common::mysql::database::backup, we are doing it in backup.sh.erb now
  }

  # Do not manage owner and group if user is allowed to SSH
  # this is to allow root owned home for a chroot
  # use ACLs to manually grant "r-x" to user_ftp and httpd_user
  if $shell != $nologin {
    file {
      "/var/www/${name}":
        ensure  => directory,
        owner   => undef,
        group   => undef,
        mode    => '0550',
        require => Package[$::httpd];
    }
  }
  else {
    file {
      "/var/www/${name}":
        ensure  => directory,
        owner   => $user_ftp,
        group   => $::httpd_user,
        mode    => '0550',
        require => Package[$::httpd];
    }
  }

  file {
    "/var/www/$name/readme.txt":
      group => $user_ftp,
      mode => '0750',
      content => template("webserver1/readme.erb"),
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/htdocs":
      owner => $user_ftp,
      group => $httpd_user,
      mode => '0750',
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/logs":
      owner => $httpd_user,
      group => $user_ftp,
      mode => '0750',
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    ["/var/www/$name/logs/access_log","/var/www/$name/logs/error_log"]:
      mode => '0644',
      owner => root,
      group => $httpd_user;
    "/var/www/$name/conf":
      owner => $httpd_user,
      group => $user_ftp,
      mode => '0755',
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/cgi-bin":
      owner => $httpd_user,
      group => $user_ftp,
      mode => '0770',
      ensure => directory,
      require => [File["/var/www/$name"],User[$user_ftp]];
    "/var/www/$name/backups":
      mode => '0750',
      ensure => directory,
      require => File["/var/www/$name"];
    "$httpd_sitedir/$name.conf":
      owner => root,
      group => $httpd_user,
      mode => '0640',
      notify => Exec["apache reload"],
      content => template("webserver1/httpd_include.conf.erb");
    "/var/www/$name/conf/vhost.conf":
      mode => '0660',
      owner => $httpd_user,
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

