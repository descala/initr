class webserver1::awstats::debian::wheezy inherits webserver1::awstats::debian {

  File["/usr/bin/awstats_updateall.pl"] {
    ensure => absent,
  }

  File["/etc/cron.d/awstats"] {
    content => template("webserver1/awstats_cron_wheezy.erb"),
  }

  File["/etc/awstats/awstats.model.conf"] {
    ensure => absent,
  }

  File["/etc/awstats/awstats.conf"] {
    ensure  => present,
    mode    => 644,
    require => Package["awstats"],
    source  => "puppet:///modules/webserver1/awstats.model.conf",
  }

}
