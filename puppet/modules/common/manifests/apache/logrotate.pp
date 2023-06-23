class common::apache::logrotate {

  file {
    "/etc/logrotate.d/$httpd_service":
      mode => "0644",
      content => template("common/apache/logrotate_httpd.erb");
  }

}
