define webserver1::awstats::domain($user, $pass) {
  
  if ( $operatingsystem == "CentOS" ) and ( $operatingsystemrelease == "4.9" ) {
  } else {
    file {
      "/etc/awstats/awstats.$name.conf":
        require => Package[awstats],
        mode => 644,
        content => template("webserver1/awstats.domain.conf.erb");
    }

    exec { "htpasswd for $user":
      command => "/usr/bin/htpasswd -b /etc/awstats/users $user $pass",
      user => root,
      unless => "grep \"^$user:\" /etc/awstats/users";
    }
  }

}

