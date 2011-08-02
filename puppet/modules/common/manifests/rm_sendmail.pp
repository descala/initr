class common::rm_sendmail {
  package { "sendmail": ensure => absent }
  package { "sendmail-cf": ensure => absent }
  package { "sendmail-base": ensure => absent }
  package { "sendmail-bin": ensure => absent }
#  service { "sendmail": ensure => absent }
}
