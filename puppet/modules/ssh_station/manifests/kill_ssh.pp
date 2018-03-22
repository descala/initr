### emergency tunnel recovery
class ssh_station::kill_ssh {
  exec { "killallssh-to-recover":
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    command => "killall -9 ssh",
  }
}

