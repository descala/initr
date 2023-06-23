class gnulinux::debian_voyage inherits gnulinux::debian {
  Package [$manpages] {ensure => absent,}
  Package ["gcc"] {ensure => absent,}
}

