class amavis($db_name,$db_passwd,$db_user) {

  case $operatingsystem {
    "Debian": { include amavis::debian }
    "CentOS": { include amavis::centos }
  }

}

class amavis::common {
  package {
    "amavisd-new":
      ensure => installed;
  }
  if array_includes($classes,"munin") {
    include amavis::munin
  }
}

class amavis::debian inherits amavis::common {

  service {
    "amavis":
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => Package["amavisd-new"];
  }

  cron {
    "purge quarantine":
      command => "find /var/lib/amavis/virusmails/ -type f -ctime +30 -delete",
      user => root,
      hour => 6,
      minute => 15;
  }

#TODO: /etc/amavis/conf.d/ files
#  file {
#    "/etc/amavisd/amavisd.conf":
#      mode => 644,
#      content => template("common/amavisd.conf.erb"),
#      require => Package["amavisd-new"],
#      notify => Service["amavis"];
#  }

}

class amavis::centos inherits amavis::common {
  Package["amavisd-new"] { require => [File["/etc/yum.repos.d/CentOS-Base.repo"],Package["rpmforge-release"]] }

  service {
    "amavisd":
      alias => "amavis",
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => false,
      pattern => "amavisd",
      require => Package["amavisd-new"];
    "clamd":
      name => "clamd.amavisd",
      enable => true,
      ensure => running,
      hasrestart => true,
      hasstatus => true,
      require => Package["amavisd-new"];
  }

  file {
    "/etc/amavisd/amavisd.conf":
      mode => 644,
      content => template("common/amavis/amavisd.conf.erb"),
      require => Package["amavisd-new"],
      notify => Service["amavisd"];
    "/etc/sysconfig/clamd.amavisd":
      source => "puppet:///modules/common/amavis/sysconfig_clamd.amavisd",
      notify => Service["clamd"];
    "/etc/clamd.d/amavisd.conf":
      mode => 644,
      source => "puppet:///modules/common/amavis/clamd_amavisd.conf",
      require => Package["clamav"],
      notify => Service["clamd"];
  }

}

class amavis::munin {

  case $operatingsystem {
    "Debian": { include amavis::munin::debian }
    "CentOS": { include amavis::munin::centos }
  }

}

class amavis::munin::common {
  package {
    "logtail":
      ensure => installed;
  }
}

class amavis::munin::debian inherits amavis::munin::common {
  file { "/etc/munin/plugin-conf.d/amavis":
    mode => 644,
    notify => Service[munin-node],
    content => "[amavis*]
us root
enlogfile /var/log/maillog"
  }
}

class amavis::munin::centos inherits amavis::munin::common {
  file { "/usr/sbin/logtail":
    mode => 755,
    source => "puppet:///modules/common/amavis/logtail",
    owner => "root",
    group => "root",
    replace => false,
  }
}

