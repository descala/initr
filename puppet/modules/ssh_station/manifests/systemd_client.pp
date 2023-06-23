class ssh_station::systemd_client inherits ssh_station::client {

  service { 'ssh_station':
    ensure   => running,
    enable   => true,
    subscribe   => File['/etc/systemd/system/ssh_station.service'],
  }

  file {
    '/etc/systemd/system/ssh_station.service':
      owner  => root,
      group  => root,
      mode   => '0644',
      source => 'puppet:///modules/ssh_station/ssh_station.service';
  }~>
  exec { 'restart_ssh_station':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}

