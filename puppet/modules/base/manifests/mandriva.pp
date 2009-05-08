# Class: mandriva
#
# Class for all Mandriva/Mandrake distributions.
class mandriva inherits gnulinux {

}

# Mandriva 10
class mandriva10 inherits mandriva {
  include ssh3
}
# Mandriva 2006.0
class mandriva2006_0 inherits mandriva {
  include ssh
}
# Class aliases
class mandrivalinux inherits mandriva { }
class mandrakelinux10_0 inherits mandriva10 { }
class mandrivalinux2006_0 inherits mandriva2006_0 { }
