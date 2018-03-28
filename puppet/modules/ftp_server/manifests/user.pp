define ftp_server::user($password) {
  user {
    $name:
      ensure => present,
      password => $password,
      home => "/home/ftpusers/$name",
      shell => $nologin;
  }
  file {
    "/home/ftpusers/$name":
      ensure => directory,
      owner => $name,
      group => $name,
      mode => $home_writeable ? {
        "1" => '0750',
        default => '0550'
      };
  }
}
