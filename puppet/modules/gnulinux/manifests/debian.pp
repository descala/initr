# Classe per a totes les Debian
class gnulinux::debian inherits gnulinux {

  # trixie ja no té el paquet "ntp": només existeix com a transicional a les
  # màquines actualitzades des de bookworm, que depèn de ntpsec
  $ntp_package = ($operatingsystem == 'Debian' and versioncmp("${lsbmajdistrelease}", '13') >= 0) ? {
    true    => 'ntpsec',
    default => 'ntp',
  }

  # el "dnsutils" que queda a les màquines actualitzades des de bookworm és el
  # transicional de bookworm: amb fonts de bookworm rep actualitzacions de
  # seguretat que unattended-upgrades no instal·larà mai
  if $operatingsystem == 'Debian' and versioncmp("${lsbmajdistrelease}", '13') >= 0 {
    package { 'dnsutils':
      ensure => purged;
    }
  }

  package {
    "lsb-release":
      ensure => present;
    $ruby_devel:
      ensure => installed;
    "debian-archive-keyring":
      ensure => latest;
    $ntp_package:
      ensure => installed;
    'curl':
      ensure => installed;
  }

  # change this file to upgrade debian with puppet
  file {
    "/etc/apt/auto_upgrade":
      schedule => 'nightly',
      source   => ["puppet:///specific/auto_upgrade", "puppet:///modules/gnulinux/debian/auto_upgrade"];
  }
  exec {
    "/usr/bin/apt-get update && /usr/bin/apt-get -y dist-upgrade":
      refreshonly => true,
      subscribe => File["/etc/apt/auto_upgrade"],
      timeout => 7200;
  }

  # etckeeper
  file {
    "/etc/shorewall/.git":
      ensure => absent,
      force => true;
    "/root/.gitconfig":
      replace => false,
      content => "[core]
    excludesfile = ~/.gitignore
[color]
    ui = true
[push]
    default = matching
[user]
    name = Root
    email = root@localhost
";
  }
  package {
    "etckeeper":
      ensure => "installed",
      require => File["/etc/shorewall/.git"];
    'locales':
      ensure => 'installed';
  }

  append_if_no_such_line { locale_ca:
    file    => '/etc/locale.gen',
    line    => 'ca_ES.UTF-8 UTF-8',
    notify  => Exec['locale-gen']
  }
  append_if_no_such_line { locale_en:
    file    => '/etc/locale.gen',
    line    => 'en_US.UTF-8 UTF-8',
    notify  => Exec['locale-gen']
  }
  exec {
    '/usr/sbin/locale-gen':
      alias       => 'locale-gen',
      require     => Package['locales'],
      refreshonly => true;
  }

}
