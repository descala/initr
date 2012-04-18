class remote_backup::server {

  include common::sshkeys
  if array_includes($classes,"nagios::nsca_node") {
    remote_backup::nagios_check_backup_files { $remote_backups: }
    create_resources(remote_backup::nagios_check_disk_used, $remote_backups_disk_usage_checks)
    file {
      "$nagios_plugins_dir/check_newest_file_age":
        mode => 755,
        source => "puppet:///modules/remote_backup/check_newest_file_age";
      "$nagios_plugins_dir/check_disk_used":
        mode => 755,
        source => "puppet:///modules/remote_backup/check_disk_used";
    }
  }

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
