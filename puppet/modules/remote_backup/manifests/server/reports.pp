class remote_backup::server::reports {

  file {
    "/var/www/remotebackup_reports/index.php":
      content => template("remote_backup/reports.php.erb");
    "/etc/apache2/remotebackup_users":
      ensure => present,
      mode => 600,
      owner => $httpd_user;
  }

  create_resources(remote_backup::server::reports::user, $remote_backups_reports_users)

}
