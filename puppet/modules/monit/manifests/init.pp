class monit {

  # don't use create_resources since $monit_checks is an array,
  # puppet accepts arrays on resource definitions
  monit::enable_check { $monit_checks: }

  package { "monit":
    ensure => installed,
  }

  file {
    "/etc/logrotate.d/monit":
      mode => '0644',
      owner => root,
      group => root,
      source => "puppet:///modules/monit/logrotate.monit";
    "$monit_d":
      mode => '0755',
      owner => root,
      group => root,
      ensure => directory,
      require => Package["monit"];
    "$monit_d/available/":
      mode => '0755',
      owner => root,
      group => root,
      ensure => directory,
      require => File["$monit_d"];
    "$monit_d/enabled/":
      mode => '0755',
      owner => root,
      group => root,
      ensure => directory,
      require => File["$monit_d"],
      backup => false,
      force => true,
      purge => true,
      recurse => true,
      # not needed on puppet 0.25
      source => "puppet:///modules/monit/empty",
      ignore => [".gitignore"];
    "$monit_d/available/apache":
      mode => '0755',
      content => template("monit/apache.erb");
    "$monit_d/available/crond":
      mode => '0755',
      content => template("monit/crond.erb");
    "$monit_d/available/mysql":
      mode => '0755',
      content => template("monit/mysql.erb");
    "$monit_d/available/postfix":
      mode => '0755',
      content => template("monit/postfix.erb");
    "$monit_d/available/puppet":
      mode => '0755',
      content => template("monit/puppet.erb");
    "$monit_d/available/samba":
      mode => '0755',
      content => template("monit/samba.erb");
    "$monit_d/available/sshd":
      mode => '0755',
      content => template("monit/sshd.erb");
    "$monit_d/available/syslogd":
      mode => '0755',
      content => template("monit/syslogd.erb");
    "$monit_d/enabled/specific":
      mode => '0700',
      owner => root,
      group => root,
      source => ["puppet:///specific/monit_specific","puppet:///modules/monit/specific"],
      notify => Service["monit"],
      require => File["$monit_d"];
  }

  case $operatingsystem {
    Debian,Ubuntu: {
      if $::operatingsystem == 'Debian' and $::lsbmajdistrelease =~ /7|8/ {
        file {
          $monitrc:
            mode => '0700',
            owner => root,
            group => root,
            source => [ "puppet:///specific/monit.conf", "puppet:///modules/monit/monitrc_debian7" ],
            notify => Service["monit"],
            require => Package["monit"];
          "/etc/default/monit":
            content => "##################
# Puppet managed #
##################
START=yes
";
        }
      } else {
        file {
          $monitrc:
            mode => '0700',
            owner => root,
            group => root,
            source => [ "puppet:///specific/monit.conf", "puppet:///modules/monit/monitrc" ],
            notify => Service["monit"],
            require => Package["monit"];
          "/etc/default/monit":
            content => "##################
# Puppet managed #
##################
startup=1
";
        }
      }
      service { "monit":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => false,
        require => Package["monit"],
        pattern => "monit",
      }
    }
    default: {
      service { "monit":
        ensure => running,
        enable => true,
        hasrestart => true,
        hasstatus => true,
        require => Package["monit"],
      }
      file {
        $monitrc:
          mode => '0700',
          owner => root,
          group => root,
          source => [ "puppet:///specific/monit.conf", "puppet:///modules/monit/monitrc_redhat" ],
          notify => Service["monit"],
          require => Package["monit"];
      }
    }
  }
}
