define remote_backup::server::reports::user($password) {

  $user= regsubst($name, 'remotebackup_(.*)', '\1')

  #TODO: On password change update user!
  exec {
    "htpasswd -b -c /etc/apache2/remotebackup_users $user $password":
      unless => "grep \"^$user:\" /etc/apache2/remotebackup_users",
      require => File["/etc/apache2/remotebackup_users"];
  }

}
