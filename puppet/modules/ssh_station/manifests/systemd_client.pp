class ssh_station::systemd_client inherits ssh_station::client {

  exec {
    'restart_ssh_station':
      command     => '/bin/systemctl restart ssh_station.service',
      subscribe   => File['/etc/systemd/system/ssh_station.service'],
      refreshonly => true;
    'install ssh_station service':
      command => '/bin/systemctl enable ssh_station.service',
      require => File['/etc/systemd/system/ssh_station.service'],
      unless  => 'test -f /etc/systemd/system/multi-user.target.wants/ssh_station.service',
      before  => Exec['restart_ssh_station'];
  }

  file {
    '/etc/systemd/system/ssh_station.service':
      owner  => root,
      group  => root,
      mode   => '0644',
      source => 'puppet:///modules/ssh_station/ssh_station.service';
  }
}

