class common::rubygems {

  include common::build_essential

  case $operatingsystem {
    "Debian": {
      package { "rubygems1.8":
        ensure => latest,
      }
      if $lsbmajdistrelease == "7" {
        package { "ruby1.9.1-dev":
          ensure => "installed",
        }
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

