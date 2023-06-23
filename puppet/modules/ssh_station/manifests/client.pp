class ssh_station::client {

  include common::openssh
  include common::sshkeys
  include ssh_station::client_user
  if array_includes($classes,"nagios::nsca_node") {
    include ssh_station::client::nagios
  }

  # choose which ssh is needed
  $sshclass = $operatingsystem ? {
    "Mandriva" => $lsbdistrelease ? {
      "10.0" => "ssh_station::ssh3",
      default => "ssh_station::ssh"
    },
    "Fedora" => $lsbdistrelease ? {
      "2" => "ssh_station::ssh3",
      default => "ssh_station::ssh"
    },
    default => "ssh_station::ssh"
  }

  case $ssh_proxytunnel {
    "true",true,"1",1: { include ssh_station::proxytunnel }
    default: { include $sshclass }
  }

  file {
    "ssh_station":
      name => "/usr/local/sbin/ssh_station",
      mode => '0700',
      owner => root,
      group => root,
      content => template("ssh_station/ssh_station.erb");
    "ssh_station_watch":
      name => "/usr/local/sbin/ssh_station_watch",
      owner => root,
      group => root,
      mode => '0700',
      source => [ "puppet:///specific/ssh_station_watch.rb", "puppet:///modules/ssh_station/ssh_station_watch.rb" ];
  }

  exec {
    "killallssh":
      command => "killall ssh",
      require => [ File["/etc/ssh/ssh_config"] ],# Sshkey["${ssh_station_server}_sshst_server"] ], #TODO
      subscribe => [ Exec["restart_ssh_station"], File["/etc/ssh/ssh_config"] ],
      refreshonly => true;
  }

  cron { "ssh_station_watch":
    command => "/usr/local/sbin/ssh_station_watch",
    user => root,
    minute => "*/15",
    require => File["ssh_station_watch"],
  }

  case $lsbdistid {
    'Debian': {
      # this package contains "killall"
      package { psmisc:
        ensure => installed,
        before => Exec[killallssh],
      }
    }
  }

  # /etc/ssh/ssh_known_hosts
  Sshkey <<| tag=="${ssh_station_server}_sshst_server" |>>

  # Ubuntu uses upstart and Debian systemd since Jessie
  case $::operatingsystem {
    'Ubuntu': {
      case $::lsbmajdistrelease {
        '8.04','14.04': { include ssh_station::upstart_client }
        default: { include ssh_station::systemd_client }
      }
    }
    'Debian': {
      case $::lsbmajdistrelease {
        '4','5','6','7': { include ssh_station::sysv_client }
        default: { include ssh_station::systemd_client }
      }
    }
    default:  { include ssh_station::sysv_client }
  }

}

