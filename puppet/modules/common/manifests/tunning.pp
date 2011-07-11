class tunning {

  # BASH
  file { "/root/.bashrc":
    mode => 644,
    owner => root,
    group => root,
    source => ["puppet:///dist/specific/$fqdn/bashrc","puppet:///modules/common/tunning/bashrc"],
  }
  file { "/root/.bash_profile":
    mode => 644,
    owner => root,
    group => root,
    source => "puppet:///modules/common/tunning/bash_profile",
  }
  # VIM
  file { "/root/.vimrc":
    mode => 644,
    owner => root,
    group => root,
    source => "puppet:///modules/common/tunning/vimrc",
  }
  package { $vim:
    ensure => present,
  }
}

