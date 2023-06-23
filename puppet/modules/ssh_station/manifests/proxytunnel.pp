# ssh connection through an http proxy server
# useful to bypass a firewall to access the internet
class ssh_station::proxytunnel inherits ssh_station::ssh {

  case $operatingsystem {
    Debian: {
      package {
        ["libssl-dev"]:
          ensure => installed;
      }
      file {
        "/usr/local/src/install_proxytunnel.sh":
          mode => '0744',
          source => "puppet:///modules/ssh_station/install_proxytunnel.sh";
        "/usr/bin/proxytunnel":
          require => Exec["/usr/local/src/install_proxytunnel.sh"],
          ensure => "/usr/local/bin/proxytunnel";
      }
      exec {
        "/usr/local/src/install_proxytunnel.sh":
          require => [File["/usr/local/src/install_proxytunnel.sh"],Package["libssl-dev"]],
          unless => "[ -f /usr/local/bin/proxytunnel ]";
      }
      File["/etc/ssh/ssh_config"] {
        content => template("ssh_station/ssh_config_with_proxytunnel.erb"),
        require => Exec["/usr/local/src/install_proxytunnel.sh"],
      }
    }
    default: {
      include ingent_common::repositorisyum::dagrepo
      package {
        "proxytunnel":
          ensure => installed,
          require => Package['rpmforge-release'];
      }
      File["/etc/ssh/ssh_config"] {
        content => template("ssh_station/ssh_config_with_proxytunnel.erb"),
        require => Package['proxytunnel'],
      }
    }
  }
}

