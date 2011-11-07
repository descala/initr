class webserver1 {

  $phpmyadmindir = $operatingsystem ? {
    Debian => "/usr/share/phpmyadmin",
    default => $lsbdistrelease ? {
      "5.4" => "/usr/share/phpMyAdmin",
      default => "/usr/share/phpmyadmin"
    }
  }
  
  include common::apache::ssl
  include common::mysql
  include common::php
  include webserver1::ftp
  include common::rsync
  include common::cron

  case $operatingsystem {
    "Debian": { include webserver1::awstats::debian }
    "CentOS": {
      case $operatingsystemrelease {
        "5.3": { include webserver1::awstats::centos53 }
        "4.9": {}
        default: { include webserver1::awstats::redhat }
      }
    }
    default: { include webserver1::awstats::redhat }
  }

  package {
    ["phpmyadmin",$php_gd]:
      ensure => installed,
      notify => Service[$httpd_service];
    $ruby_shadow:
      ensure => installed;
  }

  create_resources(webserver1::domain, $webserver_domains)

  cron { "Backup virtualhosts":
    command => "/usr/local/sbin/webserver_backup_all >> /var/log/messages 2>&1",
    hour => 3,
    minute => 30,
    require => [Package["rsync"],File["/usr/local/sbin/webserver_backup_all"]],
  }

  file {
    "/usr/local/sbin/backup.rb":
      mode => 700,
      source => "puppet:///modules/webserver1/backup.rb";
    "/etc/logrotate.d/$httpd_service":
      mode => 644,
      content => template("webserver1/logrotate_httpd.erb");
    "$phpmyadmindir/config.inc.php":
      mode => 644,
      require => [Package["phpmyadmin"],Package[$httpd]],
      content => template("webserver1/phpmyadmin_config.erb");
    "$httpd_confdir/phpmyadmin.conf":
      mode => 640,
      group => $httpd_user,
      require => Package["phpmyadmin"],
      content => template("webserver1/phpmyadmin_httpd.erb");
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

  if $operatingsystem != "Debian" {
    package {
      "php-mbstring": # for squirelmail?
        ensure => installed,
        notify => Service[$httpd_service];
    }
  }

  # TODO: make this consistent with Debian's ports.conf
  if $operatingsystem == "CentOS" {
    file {
      "$httpd_confdir/vhosts.conf":
        mode => 644,
        source => "puppet:///modules/webserver1/vhosts.conf",
        notify => Service[$httpd_service];
    }
  }

  # redirect to default domain
  ############################

  if $operatingsystem == "Debian" {
    common::apache::ensite { "default": }
    common::apache::enmod { "rewrite.load": }
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
RewriteCond %{REQUEST_URI} !^/server-status(.*) [NC]
RewriteRule ^/(.*) <%=webserver_default_domain%>/$1 [L,R]
</VirtualHost>'),
    notify => Service[$httpd_service],
  }

  
}

