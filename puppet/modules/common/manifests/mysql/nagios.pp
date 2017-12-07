class common::mysql::nagios {
  nagios::nsca_node::wrapper_check { "mysql":
    command => "$nagios_plugins_dir/check_mysql_with_passwd",
  }

  file { "$nagios_plugins_dir/check_mysql_with_passwd":
    owner => root,
    group => root,
    mode => "0700",
    content => template("common/check_mysql_with_passwd.erb"),
  }

  package { $mysql_dev:
    ensure => installed,
  }
}
