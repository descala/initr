class copier {
  file {
    "/usr/local/sbin/copiador.rb":
      mode => '0755',
      source => "puppet:///modules/copier/copiador.rb";
    "/usr/local/etc/copiador":
      ensure => directory,
      mode => '0755';
  }
  create_resources(copier::copy, $copier_copies)
}
