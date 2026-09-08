# Plugins propis nascuts de la revisió d'incidents de la farm B2Brouter
# (2026-04 → 2026-08): mesuren resultats amb dimensió de frescor, no processos
# vius. El màster és b2b_ops:scripts/nagios/ (README amb la taula nom/comanda/
# host/cadència); qualsevol canvi es fa allà i es re-copia aquí.
#
# Els fitxers són inerts si cap check els crida: els checks s'activen node a
# node des de neal (Initr::NagiosCheck). La classe s'assigna per node amb una
# CustomKlass "nagios::extra_plugins" (pilot); per anar a tota la flota Debian
# n'hi ha prou amb un include des de nagios::nsca_node::debian.
class nagios::extra_plugins {
  File {
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package[$nagios_plugins_basic],
  }
  file {
    "$nagios_plugins_dir/check_oom.rb":
      source => "puppet:///modules/nagios/check_oom.rb";
    "$nagios_plugins_dir/check_long_procs.rb":
      source => "puppet:///modules/nagios/check_long_procs.rb";
    "$nagios_plugins_dir/check_borg_config.rb":
      source => "puppet:///modules/nagios/check_borg_config.rb";
    "$nagios_plugins_dir/check_borg_repos.rb":
      source => "puppet:///modules/nagios/check_borg_repos.rb";
    "$nagios_plugins_dir/check_shorewall.rb":
      source => "puppet:///modules/nagios/check_shorewall.rb";
    "$nagios_plugins_dir/check_disk_forecast.rb":
      source => "puppet:///modules/nagios/check_disk_forecast.rb";
    "$nagios_plugins_dir/check_nfs_write_canary.rb":
      source => "puppet:///modules/nagios/check_nfs_write_canary.rb";
    "$nagios_plugins_dir/check_smart.rb":
      source => "puppet:///modules/nagios/check_smart.rb";
    "$nagios_plugins_dir/check_apt_security.rb":
      source => "puppet:///modules/nagios/check_apt_security.rb";
    "$nagios_plugins_dir/check_reboot_required.rb":
      source => "puppet:///modules/nagios/check_reboot_required.rb";
  }
}
