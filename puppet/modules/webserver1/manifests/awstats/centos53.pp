class webserver1::awstats::centos53 inherits webserver1::awstats::redhat {
  file {
    "/usr/bin/awstats_updateall.pl":
      ensure => "/usr/share/awstats/tools/awstats_updateall.pl",
      require => Package["awstats"];
    "/var/lib/awstats/awstats.pl":
      source => "/usr/share/awstats/wwwroot/cgi-bin/awstats.pl",
      require => Package["awstats"];
  }
}

