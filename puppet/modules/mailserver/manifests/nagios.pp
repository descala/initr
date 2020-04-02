# nagios checks for mail
class mailserver::nagios {
  nagios::check { 'imap':
    command => "check_imap -H localhost -e 'OK'",
  }
  nagios::check { 'pop':
    command => "check_pop -H localhost -e 'OK'",
  }
  if ($operatingsystem == 'CentOS' and $lsbmajdistrelease == '5') or
  ($operatingsystem == 'Ubuntu' and $lsbmajdistrelease == '12.04' ) {
    nagios::check { 'smtp_ssl':
      command => 'check_smtp -H localhost -S -D 30',
    }
  } else {
    nagios::check { 'smtp_ssl':
      command => 'check_smtp -H localhost -S -D 28,15',
    }
  }

  # shared checks for smtp and mail queue
  include common::postfix::nagios
}
