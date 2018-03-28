class mailserver2::nagios {
  #TODO: segur que es poden millorar aquests checks
  nagios::check { "imap":
    command => "check_imap -H localhost -e 'OK'",
  }
  nagios::check { "pop":
    command => "check_pop -H localhost -e 'OK'",
  }
  if $operatingsystem == 'CentOS' and $lsbmajdistrelease == '5' {
    nagios::check { 'smtp_ssl':
      command => 'check_smtp -H localhost -S -D 30',
    }
  } else {
    nagios::check { 'smtp_ssl':
      command => 'check_smtp -H localhost -S -D 30,15',
    }
  }

  # el check de smtp i queue els comparim amb la classe postfix
  include common::postfix::nagios
}
