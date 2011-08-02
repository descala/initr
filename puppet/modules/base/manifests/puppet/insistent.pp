class base::puppet::insistent inherits base::puppet {
  file {
    "/usr/local/sbin/puppet-run-if-needed.sh":
      owner => root,
      group => root,
      mode => 700,
      content => template("base/puppet/puppet-run-if-needed.sh.erb");
  }
  Cron["check_configuration_changes"] { ensure => present }
}

