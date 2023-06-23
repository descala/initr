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

  # awstats.*.conf and awstats.conf are parsed by update.sh,
  # rename to awstats_model.conf to avoid errors on every run
  # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=580699
  file { "/etc/awstats/awstats_model.conf":
    ensure  => present,
    mode    => "0644",
    require => Package["awstats"],
    source  => "puppet:///modules/webserver1/awstats.model.conf",
  }

}
