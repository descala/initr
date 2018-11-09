class samba {

  if !$smbdir {
    $smbdir = "/var/arxiver"
  }
  include samba::arxiver

  if array_includes($classes,"nagios::nsca_node") {
    include samba::nagios
  }
  
  package { [samba,$smbclient]: ensure => installed, }

  file {
    '/etc/samba/smb.conf':
      mode => '0644',
      owner => root,
      group => root,
      source => "puppet:///specific/smb.conf",
      notify => Service[$samba_service],
      require => Package['samba'];
    "${rubysitedir}/facter":
      ensure => directory;
    "${rubysitedir}/facter/localsid.rb":
      source => "puppet:///modules/samba/facter/localsid.rb",
      mode => '0644', owner => root, group => root;
    "/etc/samba/":
      ensure => directory,
      mode => '0755', owner => root, group => root;
  }

  case $operatingsystem {
    "Debian": {
      service { $samba_service:
        require => Package[samba],
        enable => true,
        ensure => running,
        hasrestart => true,
        hasstatus => false,
        pattern => "smbd",
      }
    }
    default: {
      service { $samba_service:
        name => 'smb',
        require => Package[samba],
        enable => true,
        ensure => running,
        hasrestart => true,
        restart => '/etc/init.d/smb reload',
        hasstatus => true,
        pattern => "smbd",
      }
    }
  }

  cron {
    "cp_tdb_baks":
     command => "/bin/cp $samba_tdb_dir/*.tdb* $smbdir/documents/.ingent/",
      hour => 4, minute => 00,
      user => root,
      require => Package['samba'];
    "tdb_backup":
      command => "/usr/bin/tdbbackup $samba_tdb_dir/*.tdb /etc/samba/*.tdb",
      hour => 4, minute => 30,
      user => root,
      require => Package['samba'];
  }
}

