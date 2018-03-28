define munin::plugin($script_path = "/usr/share/munin/plugins") {
  if $name =~ /^if_eth/ {
    $plugin="if_"
  } else {
    if $name =~ /^if_errors_eth/ {
      $plugin="if_err_"
    } else {
      $plugin=$name
    }
  }
  file { "/etc/munin/plugins/$name":
    ensure => "$script_path/$plugin",
    notify => Service["munin-node"],
    require => Package[$munin];
  }
}

