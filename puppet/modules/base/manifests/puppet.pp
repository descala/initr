class puppet {
  case $operatingsystem {
    "CentOS","Fedora","Mandriva": {
      # puppet < 0.25 install from rubygems or source
      #TODO: newer versions of these OS have puppet > 0.25, check which ones.
    }
    default: {
      package {
        ["puppet","facter"]:
          ensure => installed,
          notify => Service["puppet"];
      }
    }
  }
  service {
    "puppet":
      enable => true,
      ensure => running;
  }
  file {
    "/usr/local/sbin/puppet-restart.sh":
      owner => root,
      group => root,
      mode => 744,
      before => Service["puppet"],
      source => "puppet:///modules/base/puppet/puppet-restart.sh";
  }
  cron {
    puppet_restart:
      command => "/usr/local/sbin/puppet-restart.sh &> /dev/null",
      before => Service["puppet"],
      user => root,
      hour => 5,
      minute => 10;
    "check_configuration_changes":
      command => "/usr/local/sbin/puppet-run-if-needed.sh &> /dev/null",
      before => Service["puppet"],
      ensure => absent;
  }
}

class puppet::lite inherits puppet {
  Service["puppet"] {
    enable => false,
  }
  File["/usr/local/sbin/puppet-restart.sh"] {
    source => ["puppet:///dist/specific/$fqdn/puppet-restart.sh","puppet:///modules/base/puppet/puppet-lite-restart.sh"],
  }
}

class puppet::insistent inherits puppet {
  file {
    "/usr/local/sbin/puppet-run-if-needed.sh":
      owner => root,
      group => root,
      mode => 700,
      content => template("base/puppet/puppet-run-if-needed.sh.erb");
  }
  Cron["check_configuration_changes"] { ensure => present }
}
