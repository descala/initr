define copier::verify_copy($dir,$warn,$crit,$fs) {
  # nagios check to verify if backup data is current
  nagios::check { "${name}_is_current":
    command => "check_file_age -w $warn -c $crit -f $dir/.last_copy",
    minute => 5,
    hour => '*/4', # every four hours
    freshness => $warn,
  }

  # nagios service notified when backup ends
  # warn + 1 hour
  $freshness = $warn + 3600
  nagios::service { $name:
    freshness => $freshness,
  }
}
