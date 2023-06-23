define copier::copy($source,$destination,$historic,$bdays,$fs,$excludes,$options,$mount_type,$mount_file_to_check,$minute,$hour,$weekday,$monthday,$warn,$rsyncd_password,$email) {
  if array_includes($classes,"nagios::nsca_node") {
    $crit = $warn * 1.5
    $warning = $warn + 3600
    copier::verify_copy {
      $name:
        dir => $destination,
        warn => $warning,
        crit => $crit,
        fs => $fs;
    }
  }
  if $fs == "rdiff-backup" {
    include common::rdiff_backup
  } else {
    include common::rsync
  }
  file {
    "/usr/local/etc/copiador/config_${name}.yml":
      mode => '0644',
      content => template("copier/copiador.yml.erb"),
      require => File["/usr/local/etc/copiador"];
    "/usr/local/etc/copiador/${name}_excludes":
      mode => '0644',
      content => $excludes,
      require => File["/usr/local/etc/copiador"];
  }
  # workaround for bug http://projects.reductivelabs.com/issues/1728
  cron { "backup_$name":
    command => "/usr/local/sbin/copiador.rb /usr/local/etc/copiador/config_${name}.yml > /dev/null 2>&1",
    user => root,
    require => [ File["/usr/local/sbin/copiador.rb"], File["/usr/local/etc/copiador/config_${name}.yml"] ],
    hour => $hour ? {
      "*" => absent,
      default => $hour,
    },
    minute => $minute ? {
      "*" => absent,
      default => $minute,
    },
    weekday => $weekday ? {
      "*" => absent,
      default => $weekday,
    },
    monthday => $monthday ? {
      "*" => absent,
      default => $monthday,
    },
  }
  file {
    "/etc/logrotate.d/copier_$name":
      mode => '0644',
      content => template("copier/logrotate.erb");
    "/var/log/$name":
      mode => '0660',
      ensure => present;
  }
}

