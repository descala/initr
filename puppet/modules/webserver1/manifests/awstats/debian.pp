class webserver1::awstats::debian inherits webserver1::awstats {
  file {
    "/etc/cron.d/awstats":
      mode => "0755",
      content => template("webserver1/awstats_cron.erb"),
      notify => Service[$cron_service];
    "${::httpd_confdir}/awstats.conf":
      mode => "0644",
      owner => $httpd_user,
      group => $httpd_user,
      content => template("webserver1/awstats_httpd.conf.erb"),
      require => Package[$httpd],
      notify => Exec["apache reload"];
    "/usr/bin/awstats_updateall.pl":
      mode => "0750",
      group => "www-data",
      source => "/usr/share/doc/awstats/examples/awstats_updateall.pl",
      require => Package["awstats"];
  }
}

