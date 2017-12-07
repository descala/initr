class remote_backup::server::munin {

  include common::munin::server
  include common::apache

  file {
    "/etc/munin/munin.conf":
      content => template("remote_backup/munin.conf.erb");
    "/var/www/remotebackup_reports":
      ensure => directory;
    "/usr/share/munin/plugins/remotebackup_":
      mode => 755,
      content => template("remote_backup/munin_graph.erb");
    "/etc/munin/plugin-conf.d/remotebackup_":
      content => "[remotebackup_*]
    user root";
  }

  case $operatingsystem {
    "Debian": {
      file { "/etc/apache2/sites-available/remotebackup_reports":
        notify => Service[$httpd_service],
        content => template("remote_backup/reports_httpd.conf.erb");
      }
      common::apache::ensite { "remotebackup_reports": }
    }
    default: {
      file { "/etc/httpd/conf.d/remotebackup_reports.conf":
        notify => Service[$httpd_service],
        content => template("remote_backup/reports_httpd.conf.erb");
      }
    }
  }

}
