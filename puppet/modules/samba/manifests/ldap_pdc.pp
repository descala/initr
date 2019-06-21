# TODO: only tested on Debian
class samba::ldap_pdc inherits samba {

  include samba::ldap

  # /etc/samba/smb.conf is a template
  # it includes /etc/samba/smb_shares.conf
  File['/etc/samba/smb.conf'] {
    source  => undef,
    content => template('samba/smb_ldap_pdc.conf.erb'),
    notify  => Exec['set ldap password'],
  }

  file {
    "${smbdir}/home":
      ensure => directory;
    '/etc/samba/smbusers':
      source => 'puppet:///modules/samba/smbusers';
    '/etc/smbldap-tools/smbldap.conf':
      content => template('samba/smbldap.conf.erb');
    '/etc/smbldap-tools/smbldap_bind.conf':
      mode    => '0600',
      content => template('samba/smbldap_bind.conf.erb');
    '/etc/libnss-ldap.conf':
      mode    => '0644',
      content => template('samba/libnss-ldap.conf.erb');
    '/etc/libnss-ldap.secret':
      mode    => '0600',
      content => template('samba/libnss-ldap.secret.erb');
    '/etc/nsswitch.conf':
      source => 'puppet:///modules/samba/nsswitch.conf';
  }
  package {
    [acl,libnss-ldap,ldap-utils,samba-common]:
      ensure => installed;
  }
  exec{
    'zcat /usr/share/doc/samba/examples/LDAP/samba.schema.gz > /etc/ldap/schema/samba.schema':
      require => Package[samba],
      creates => '/etc/ldap/schema/samba.schema';
    "smbpasswd -w $ldappasswd":
      alias       => 'set ldap password',
      require     => Package[samba-common],
      refreshonly => true;
  }
}

