class common::postfix::nagios {
  nagios::check { "smtp":
    command => "check_smtp -H localhost -w 10 -c 20 -t 30",
  }
  # Usage: check_mailq -w <warn> -c <crit> [-W <warn>] [-C <crit>] [-M <MTA>] [-t <timeout>] [-v verbose]
  # Checks the number of messages in the mail queue
  if $mailq_warn {
    $mqw=$mailq_warn
  } else {
    $mqw=100
  }
  nagios::check { "check_mailq":
    command => "check_mailq -w $mqw -c 1000 -t 30 -M postfix",
  }
  if $skip_blacklist_check {
  } else {
    include nagios::check_blacklisted
  }
}

