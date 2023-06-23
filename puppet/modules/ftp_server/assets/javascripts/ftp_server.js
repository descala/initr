function add_fields(link, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_ftp_users", "g");
  $(link).parent().append(content.replace(regexp, new_id));
}

