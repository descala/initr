class remote_backup::server {

  include common::sshkeys

  Ssh_authorized_key <<| tag == "${node_hash}_remote_backup_client" |>>
  File <<| tag == "${node_hash}_remote_backup_client" |>>

  file {
    $remotebackups_path:
      ensure => "directory";
  }

  # there is also rssh, but unfortunately it only works on debian backup servers
  # only debian applies a patch which allows rsync's -e option
  case $operatingsystem {
    "Debian": {
       include common::rssh
       User <<| tag == "${node_hash}_remote_backup_client" |>> {
         shell => "/usr/bin/rssh"
       }
    }
    default: {
       User <<| tag == "${node_hash}_remote_backup_client" |>>
    }
  }

}
