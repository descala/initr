class webserver1 {

  include common::apache::ssl
  include common::mysql
  include webserver1::ftp
  include common::rsync
  include common::cron

  if $manage_php == "1" {
    include common::php
    class { "common::phpmyadmin":
      accessible_phpmyadmin => $accessible_phpmyadmin,
      blowfish_secret => $blowfish_secret
    }
  }

  case $operatingsystem {
    "Debian": {
      case $lsbmajdistrelease {
        "8": { include webserver1::awstats::debian::jessie }
        "7": { include webserver1::awstats::debian::wheezy }
        default: { include webserver1::awstats::debian }
      }
    }
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
      mode => "0700",
      source => ["puppet:///specific/webserver_backup.rb", "puppet:///modules/webserver1/backup.rb"];
    "/etc/logrotate.d/webserver1":
      mode => "0644",
      content => template("webserver1/logrotate.erb");
    "/usr/local/sbin/webserver_backup_all":
      mode => "0700",
      content => template("webserver1/backup_all.sh.erb");
    "/usr/local/sbin/webserver_restore":
      mode => "0700",
      content => template("webserver1/restore.sh.erb");
    "/usr/local/sbin/webserver_backup":
      mode => "0700",
      content => template("webserver1/backup.sh.erb");
    "/usr/local/sbin/webserver_restore_all":
      mode => "0700",
      content => template("webserver1/restore_all.sh.erb");
    '/var/www':
      ensure => directory,
      mode   => '0751',
      owner  => root,
      group  => root;
  }

  if $operatingsystem != "Debian" and $manage_php == "1" {
    package {
      "php-mbstring": # for squirelmail?
        ensure => installed,
        notify => Exec["apache reload"];
    }
  }

  # TODO: make this consistent with Debian's ports.conf
  if $operatingsystem == "CentOS" {
    file {
      "$httpd_confdir/vhosts.conf":
        mode => "0644",
        source => "puppet:///modules/webserver1/vhosts.conf",
        notify => Exec["apache reload"];
    }
  }

  # redirect to default domain
  ############################

  if $manage_default_domain == "1" {
    if $operatingsystem == "Debian" {
      if $lsbmajdistrelease == '8' {
        common::apache::ensite { "000-default.conf": }
      } else {
        common::apache::ensite { "default": }
      }
      common::apache::enmod { "rewrite.load": }
    } else {
      file {
        "$httpd_sitedir/000-default.conf":
          ensure => "$httpd_sitedir/default",
      }
    }
  
    if $operatingsystem == "Debian" and $lsbmajdistrelease == '8' {
      file {
        "$httpd_sitedir/000-default.conf":
          content => inline_template('# Puppet managed
<VirtualHost *:80>
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/server-status(.*) [NC]
RewriteRule ^/(.*) <%=@webserver_default_domain%>/$1 [L,R]
</VirtualHost>'),
          require => Package[$httpd],
          notify => Exec["apache reload"];
      }
    } else {
      file {
        "$httpd_sitedir/default":
          content => inline_template('# Puppet managed
<VirtualHost *:80>
RewriteEngine On
RewriteCond %{REQUEST_URI} !^/server-status(.*) [NC]
RewriteRule ^/(.*) <%=@webserver_default_domain%>/$1 [L,R]
</VirtualHost>'),
          require => Package[$httpd],
          notify => Exec["apache reload"];
      }
    }
  }

}

