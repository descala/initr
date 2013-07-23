class webserver1::awstats::debian::wheezy inherits webserver1::awstats::debian {

  File["/usr/bin/awstats_updateall.pl"] {
    ensure => absent,
  }

  File["/etc/cron.d/awstats"] {
    content => template("webserver1/awstats_cron_wheezy.erb"),
  }

}
