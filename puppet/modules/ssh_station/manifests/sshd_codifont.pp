class ssh_station::sshd_codifont inherits ssh_station::sshd {

  # Que es pugui accedir desde qualsevol IP, pero nomes amb usuari i clau privada.
  # Fer un usuari david i autoritzar-hi la clau publica del PC del David en tots els servidors.
  # Per la connexio entre servidors, generar un parell de claus protegides amb contrasenya
  # per cadascun i autoritzar-los entre ells (de root a root)

  case $fqdn {
    "puigperic-clone.districenter.es", "puigperic.districenter.es","cypher.matrixhasyou.net": {
      File["sshdconfig"] {
        source => "puppet:///codifont/sshd_config_v3",
      }
    }
    default: {
      File["sshdconfig"] {
        source => [ "puppet:///specific/sshd_config", "puppet:///codifont/sshd_config" ],
      }
    }
  }

  user { "david":
    comment => "David Vinyals",
    ensure => present,
    home => "/home/david",
    shell => "/bin/bash",
  }

  file {
    "/home/david/.ssh":
      ensure => directory,
      mode => '0700',
      owner => david,
      group => david,
      require => User['david'];
    "/home/david/.ssh/authorized_keys":
      mode => '0644',
      owner => david,
      group => david,
      require => [ User['david'], File["/home/david/.ssh"] ],
      source => "puppet:///codifont/authorized_keys";
    '/root/.ssh':
      ensure => directory,
      mode   => '0700',
      owner  => root,
      group  => root;
    '/root/.ssh/authorized_keys':
      mode    => '0644',
      owner   => root,
      group   => root,
      require => File['/root/.ssh'],
      source  => 'puppet:///codifont/authorized_keys_root';
  }

  exec { "genkeys":
    command => "ssh-keygen -t dsa -f /home/david/.ssh/id_dsa -N ''",
    creates => "/home/david/.ssh/id_dsa",
    require => File["/home/david/.ssh"],
    user => david,
  }

}
