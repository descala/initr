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
      source => ["puppet:///specific/webserver_backup.rb", "puppet:///modules/webserver1/backup.rb"];
    "/etc/logrotate.d/webserver1":
      mode => 644,
      content => template("webserver1/logrotate.erb");
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
        mode => 644,
        source => "puppet:///modules/webserver1/vhosts.conf",
        notify => Exec["apache reload"];
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
      require => Package[$httpd],
      notify => Exec["apache reload"];
  }

  
}

