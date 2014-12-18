class common::dovecot::debian6 inherits common::dovecot::debian {

    File['/etc/dovecot/dovecot.conf'] {
      source  => 'puppet:///modules/common/dovecot/dovecot_debian_squeeze.conf',
      content => undef,
    }
}
