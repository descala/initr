# Module: base
# Includes operating system specific class
import "*.pp"

class base {

  $osavn = "${lsbdistid}${lsbdistrelease_class}"

  # include the OS class
  case $osavn {
    "": {
      warning("'$fqdn': Could not get Operating System type, install lsb or check facter")
      if defined($operatingsystem) {
        notice("'$fqdn': Using generic Operating System type '$operatingsystem'")
        include $operatingsystem
      }
    }
    default: {
      if defined($osavn)
      {
        notice("'$fqdn': Using Operating System type '$osavn'")
        include $osavn
      }
      else
      {
        if defined($lsbdistid)
        {
          include $lsbdistid
          notice("'$fqdn': Using generic Operating System type '$lsbdistid' instead of '$osavn'")
        }
        else
        {
          warning("'$fqdn': Operating System id='${lsbdistid}' release='${lsbdistrelease}' not configured")
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

