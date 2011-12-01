define configuration_errors::errors() {

  # log at server side
  err("$fqdn: $name")

  # log at client side
  notify { "$fqdn: $name": }

}
