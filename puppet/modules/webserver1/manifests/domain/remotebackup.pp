define webserver1::domain::remotebackup($web_backups_server, $backups_path) {

  $ensure = $web_backups_server ? {
    "" => "absent",
    default => "present"
  }

  Sshkey <<| tag == "${web_backups_server}_web_backups_server" |>>

  @@ssh_authorized_key { "backups for $name":
    ensure => $ensure,
    key => $sshdsakey,
    type => "dsa",
    options => "no-port-forwarding",
    user => $name,
    target => "$backups_path/webservers/$name/.ssh/authorized_keys",
    require => [ File["$backups_path/webservers/$name"], User[$name] ],
    tag => "${web_backups_server}_web_backups_client",
  }

  # user to do backups
  @@user { $name:
    ensure => $ensure,
    comment => "puppet managed, backups for $name",
    home => "$backups_path/webservers/$name",
    shell => "/bin/bash",
    tag => "${web_backups_server}_web_backups_client",
  }

  # don't remove backups automatically
  if $ensure == "present" {
    @@file {
      "$backups_path/webservers/$name":
        ensure => directory,
        owner => $name,
        group => $name,
        mode => 750,
        require => [User[$name],File["$backups_path/webservers"]],
        tag => "${web_backups_server}_web_backups_client";
      "$backups_path/webservers/$name/.ssh/authorized_keys":
        owner => $name,
        mode => 0640,
        tag => "${web_backups_server}_web_backups_client";
      "$backups_path/webservers/$name/.ssh":
        owner => $name,
        mode => 0700,
        tag => "${web_backups_server}_web_backups_client";
    }
  }

}

