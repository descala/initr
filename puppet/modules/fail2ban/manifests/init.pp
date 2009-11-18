# fail2ban puppet module
# it expects $fail2ban_jails to be an array of jails to be enabled
# and $mailto an email address to send notifications to.
class fail2ban {

  if $fail2ban_jails {
  } else {
    $fail2ban_jails=[]
  }

  package {
    [ "fail2ban", "gamin", "iptables" ]:
      ensure => installed;
  }

  service {
    "fail2ban":
      ensure => running,
      enable => true;
  }

  file {
    "/etc/fail2ban/filter.d/mail.conf":
      mode => 644,
      owner => root,
      group => root,
      source => "puppet:///fail2ban/mail.conf",
      require => Package["fail2ban"],
      notify => Service["fail2ban"];
    "/etc/fail2ban/jail.local":
      mode => 644,
      owner => root,
      group => root,
      content => template("fail2ban/jail.local.erb"),
      require => Package["fail2ban"],
      notify => Service["fail2ban"];
  }

}