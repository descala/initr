# fail2ban puppet module
# it expects $jails to be an array of jails to be enabled
# and $mailto an email address to send notifications to.
# $custom_jails are additional custom jails
class fail2ban($jails=[],$mailto="",$custom_jails="") {

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
      source => "puppet:///modules/fail2ban/mail.conf",
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

  # munin
  if array_includes($classes,"munin") {
    file {
      "/etc/munin/plugins/fail2ban_all_jails":
        mode => 755,
        source => "puppet:///modules/fail2ban/munin-fail2ban_all_jails",
        require => $operatingsystem ? {
          Gentoo => Package["munin"],
          default => Package["munin-node"],
        },
        notify => Service["munin-node"];
      "/etc/munin/plugin-conf.d/fail2ban_all_jails":
        content => "[fail2ban_all_jails]
user root",
        require => Package[$munin],
        notify => Service["munin-node"];
    }
  }

}
