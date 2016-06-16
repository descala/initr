class common::amavis::munin::debian inherits common::amavis::munin::common {
  file { "/etc/munin/plugin-conf.d/amavis":
    mode => 644,
    notify => Service[munin-node],
    content => "[amavis*]
group adm
env.enlogfile /var/log/maillog
env.logtail /usr/sbin/logtail"
  }
}


