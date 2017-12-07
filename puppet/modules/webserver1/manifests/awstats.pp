class webserver1::awstats {

  include common::perl
  include common::cron

  package {
    "awstats":
      ensure => installed;
  }

  file {
    "/etc/awstats":
      ensure => directory,
      recurse => true,
      purge => true;
    "/etc/awstats/users":
      owner => root,
      group => $httpd_user,
      mode => "0640";
    ["/etc/awstats/awstats.conf","/etc/awstats/awstats.conf.local"]:
      ensure => absent;
    "/etc/awstats/awstats.model.conf":
      mode => "0644",
      require => Package["awstats"],
      source => "puppet:///modules/webserver1/awstats.model.conf";
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

