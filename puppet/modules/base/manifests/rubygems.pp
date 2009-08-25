class rubygems {

  case $operatingsystem {
    "Debian": {
      package { "rubygems":
        ensure => latest,
      }
    }
    default: {
      # do not use 1.1.1
      $rubygems="rubygems-1.3.5"
      package { "make":
        ensure => installed,
      }
      exec { "install-rubygems":
        command => "wget http://rubyforge.org/frs/download.php/60718/$rubygems.tgz ; tar xvzf $rubygems.tgz ; rm $rubygems.tgz",
        cwd => "/usr/local/src/",
        creates => "/usr/local/src/$rubygems",
        before => Exec["ruby setup.rb"],
        require => [ Package["wget"], Package[$ruby] ],
        notify => Exec["ruby setup.rb"],
      }
      exec { "ruby setup.rb":
        cwd => "/usr/local/src/$rubygems",
        onlyif => "test -z \"$rubygems_version\"",
        unless => "test -f /usr/bin/gem",
      }
    }
  }

}

define gem_package($ensure=installed) {
  case $rubygems_version {
    "": {
      warning("Rubygems not installed: can not manage '$name' package")
      package { $name: } # dummy definition, allows requires
    }
    default: {
      package { $name:
        provider => gem,
        ensure => $ensure,
      }
    }
  }
}
