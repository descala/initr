class apache_for_initr inherits apache::ssl {
  
  file { "/etc/httpd/conf.d/initr.conf":
    owner => root,
    group => root,
    mode => 644,
    content => template("base/initr.conf.erb"),
    notify => Service[$httpd_service],
  }
}
