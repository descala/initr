# get_services.rb puppet module


class base::get_services {

  # directory /etc/in
  file {
    "/etc/in":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # file /etc/in.conf
  # PRECAUCIO: el fitxer in.conf ha d'anar sense api-keys
  file {
    "/etc/in/in.conf":
    owner => root,
    group => root,
    mode => "0644",
    ensure  => present,
    replace => "no",
    source => "puppet:///modules/base/puppet/in.conf",
  }

  # file get_services.rb
  file {
    "/usr/local/sbin/get_services.rb":
    owner => root,
    group => root,
    mode => "0744",
    ensure  => present,
    source => "puppet:///modules/base/puppet/get_services.rb",
    notify => Exec['execute_get_services'],
  }

  # exec nomes s'executa el primer cop que es copia el fitxer, o quan es modifica
  exec {
    'execute_get_services':
    command => '/usr/local/sbin/get_services.rb 1> /etc/in/services_list.json 2> /etc/in/outdated_services.json',
    refreshonly => true,
  }

  # get_services cron
  cron {
    "get_services":
    minute      => '40',
    hour        => '2',
    month       => '*',
    weekday     => '*',
    user        => 'root',
    command     => '/usr/local/sbin/get_services.rb 1> /etc/in/services_list.json 2> /etc/in/outdated_services.json',
  }

}
