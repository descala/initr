class tunning {

  ##### root #####
  # Personalitzacio BASH
  file { "/root/.bashrc":
    mode => 644,
    owner => root,
    group => root,
    source => ["puppet:///dist/specific/$fqdn/bashrc","puppet:///base/tunning/bashrc"],
  }
  file { "/root/.bash_profile":
    mode => 644,
    owner => root,
    group => root,
    source => "puppet:///base/tunning/bash_profile",
  }
  # Personalitzacio VIM
  file { "/root/.vimrc":
    mode => 644,
    owner => root,
    group => root,
    source => "puppet:///base/tunning/vimrc",
  }
  package { $vim:
    ensure => present,
  }
}

