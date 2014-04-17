class base::puppet::lite_insistent inherits base::puppet::lite {
  file {
    "/usr/local/sbin/puppet-run-if-needed.sh":
      before => Service["puppet"],
      owner => root,
      group => root,
      mode => 700,
      content => template("base/puppet/puppet-run-if-needed.sh.erb");
  }
  Cron["check_configuration_changes"] {
    before => Service["puppet"],
    ensure => present
  }
}

