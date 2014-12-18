function add_fields(link, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_custom_klass_conf", "g");
  $(link).parent().append(content.replace(regexp, new_id));
}

function rm_field(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).parents(".custom_klass_conf").hide();
}
