class tunning {

  ##### root #####
  # Personalitzacio BASH
  file { "/root/.bashrc":
    mode => 644,
    owner => root,
    group => root,
    source => ["puppet:///dist/specific/$fqdn/bashrc","puppet:///modules/base/tunning/bashrc"],
  }
  file { "/root/.bash_profile":
    mode => 644,
    owner => root,
    group => root,
    source => "puppet:///modules/base/tunning/bash_profile",
  }
  # Personalitzacio VIM
  file { "/root/.vimrc":
    mode => 644,
    owner => root,
    group => root,
    source => "puppet:///modules/base/tunning/vimrc",
  }
  package { $vim:
    ensure => present,
  }
}

