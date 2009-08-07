# site.pp

# TODO: find a way to handle globals through a module

# Default path
Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

# Default user for files
File {
  owner => "root",
  group => "root"
}

# Manage root's crontab
Cron { user => "root" }
