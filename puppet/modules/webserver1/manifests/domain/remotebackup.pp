define webserver1::domain::remotebackup($web_backups_server, $backups_path) {

  $ensure = $web_backups_server ? {
    "" => "absent",
    default => "present"
  }

  ######################################################################
  # Warn: if ftp user is equal to the domain name, puppet can't run    #
  # ("Duplicate definition: User[domain_name]"), so we check this here #
  # and add backups_ prefix if it match                                #
  ######################################################################
  if $name == $user_ftp {
    $username = "backups_$name"
  } else {
    $username = $name
  }

  Sshkey <<| tag == "${web_backups_server}_web_backups_server" |>>

  @@ssh_authorized_key { "backups for $name":
    ensure => $ensure,
    key => $sshdsakey,
    type => "dsa",
    options => "no-port-forwarding",
    user => $username,
    target => "$backups_path/webservers/$name/.ssh/authorized_keys",
    require => [ File["$backups_path/webservers/$name"], User[$username] ],
    tag => "${web_backups_server}_web_backups_client",
  }

  # user to do backups
  @@user { $username:
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
        owner => $username,
        group => $username,
        mode => 750,
        require => [User[$username],File["$backups_path/webservers"]],
        tag => "${web_backups_server}_web_backups_client";
      "$backups_path/webservers/$name/.ssh/authorized_keys":
        owner => $username,
        mode => 0640,
        tag => "${web_backups_server}_web_backups_client";
      "$backups_path/webservers/$name/.ssh":
        owner => $username,
        mode => 0700,
        tag => "${web_backups_server}_web_backups_client";
    }
  }

}

