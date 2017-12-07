class common::tunning {

  # BASH
  file { "/root/.bashrc":
    mode => "0644",
    owner => root,
    group => root,
    source => ["puppet:///specific/bashrc","puppet:///modules/common/tunning/bashrc"],
  }
  file { "/root/.bash_profile":
    mode => "0644",
    owner => root,
    group => root,
    source => "puppet:///modules/common/tunning/bash_profile",
  }
  # VIM
  file { "/root/.vimrc":
    mode => "0644",
    owner => root,
    group => root,
    source => "puppet:///modules/common/tunning/vimrc",
  }
  package { $vim:
    ensure => present,
  }
}

