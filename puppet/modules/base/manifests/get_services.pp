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
  file {
    "/etc/in/in.conf":
    owner => root,
    group => root,
    mode => "0644",
    ensure  => present,
    replace => "no",
    source => "puppet:///modules/base/puppet/in.conf",
    notify => Exec['execute_get_services'],
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

  # exec s'executa amb notify => Exec[]
  exec {
    'execute_get_services':
    command => '/usr/local/sbin/get_services.rb > /etc/in/services_list.json',
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
    command     => '/usr/local/sbin/get_services.rb > /etc/in/services_list.json',
  }

}
