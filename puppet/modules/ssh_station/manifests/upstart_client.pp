class ssh_station::upstart_client inherits ssh_station::client {
  exec { 'restart_ssh_station':
    command => 'initctl stop ssh_station; initctl start ssh_station',
    subscribe => File['/etc/init/ssh_station.conf'],
    refreshonly => true;
  }
  file { '/etc/init/ssh_station.conf':
    content => "# ssh_station
# This service mantains an ssh tunnel to a server 
start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]
respawn
exec /usr/local/sbin/ssh_station",
    require => [ File["/etc/ssh/ssh_config"], File["ssh_station"] ];
  }
}

