class gnulinux {

  package {
    [$dnsutils,$manpages,'wget','gcc','screen']:
      ensure => installed;
    'logwatch':
      ensure => absent;
  }

  include common::tunning

  # remove 'usuari' user only if it is pressent in /etc/passwd
  # this prevents errors when 'usuari' is a valid user in LDAP
  exec { '/usr/sbin/userdel usuari':
    onlyif => '/bin/grep "^usuari:" /etc/passwd';
  }

  # remove puppet ca crl to prevent it from expiring
  # https://tickets.puppetlabs.com/browse/PUP-2310
  exec { 'rm /var/lib/puppet/ssl/crl.pem':
    onlyif => '[ $(find /var/lib/puppet/ssl/crl.pem -ctime +90) ]';
  }

}

