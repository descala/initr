# Module: base
# Includes operating system specific class

class base {

  $osavn = "gnulinux::${lsbdistid}${lsbdistrelease_class}"
  $osavn_major = "gnulinux::${lsbdistid}${lsbmajdistrelease}"

  # include the OS class, this expects a module "gnulinux" with classes for each distro.
  # it tries to include specific class, then goes more generic.
  # For instance, with Debian 6.0.2 tries to include gnulinux::debian6_0_2,
  # then gnulinux::debian6, gnulinux::debian and finally gnulinux
  case $osavn {
    "": {
      warning("'$fqdn': Could not get Operating System type, install lsb or check facter")
      if defined($operatingsystem) {
        notice("'$fqdn': Using generic Operating System type '$operatingsystem'")
        include $operatingsystem
      }
    }
    default: {
      if defined($osavn) {
        notice("'$fqdn': Using Operating System type '$osavn'")
        include $osavn
      } else {
        if defined($osavn_major) {
          include $osavn_major
          notice("'$fqdn': Using Operating System type '$osavn_major'")
        } else {
          if defined("gnulinux::$lsbdistid") {
            include "gnulinux::$lsbdistid"
            notice("'$fqdn': Using generic Operating System type 'gnulinux::$lsbdistid' instead of '$osavn_major'")
          } else {
            if defined("gnulinux") {
              include "gnulinux"
              warning("'$fqdn': Using generic Operating System type 'gnulinux' instead of '$osavn_major'")
            } else {
              warning("'$fqdn': Operating System id='${lsbdistid}' release='${lsbdistrelease}' not configured")
            }
          }
        }
      }
    }
  }

  # includes a class called after the node FQDN
  # after de OS choice, to allow overrides
  if defined($fqdnclass) {
    include $fqdnclass
  }
}

