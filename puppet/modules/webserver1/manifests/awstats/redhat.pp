class webserver1::awstats::redhat inherits webserver1::awstats {
  file {
    "/etc/cron.hourly/00awstats":
      mode => 755,
      content => template("webserver1/awstats_cron.erb"),
      notify => Service[$cron_service];
    "/etc/httpd/conf.d/awstats.conf":
      mode => "0644",
      content => template("webserver1/awstats_httpd.conf.erb"),
      require => Package[$httpd],
      notify => Exec["apache reload"];

    # TODO: why do we need this?
    #    "/var/lib/awstats":
    #      source => "/var/www/awstats",
    #      recurse => true;
    
  }
}

