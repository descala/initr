class remote_backup::server {

  include common::sshkeys

  Ssh_authorized_key <<| tag == "${node_hash}_remote_backup_client" |>>
  File <<| tag == "${node_hash}_remote_backup_client" |>>

  file {
    $remotebackups_path:
      ensure => "directory";
  }

  include common::rssh
  User <<| tag == "${node_hash}_remote_backup_client" |>>

  if array_includes($classes,"nagios::nsca_node") {
    include remote_backup::server::nagios
  }
  include remote_backup::server::munin
  include remote_backup::server::reports

}
