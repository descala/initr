define webserver1::logrotate_rails($rails_root,$username) {
  file {
    "/etc/logrotate.d/rails_$name":
      content => template("webserver1/logrotate_rails.erb");
  }
}
