class initr_gem {
  $version="0.0.1"
  exec { "gemrepo":
    path => "/usr/bin:/bin",
    command => "gem sources --add http://www.ingent.net/gem_repo",
    onlyif => "test -z \"$(gem sources | grep www.ingent.net)\"",
    require => Exec["install-rubygems"],
  }

  gem_package { "initr":
  }
  #TODO: create fact to retrieve gem installation directory (gem environment gemdir) to set cwd
  $gemdir="/usr/lib64/ruby/gems/1.8"

  exec { "dbmigrate":
    cwd => "$gemdir/gems/initr-$version",
    path => "/usr/bin",
    command => "rake db:migrate RAILS_ENV=production",
    # only if current version differs from last migration version and puppetmaster has filled his database schema
    onlyif => "[ \"$initrdbversion\" != \"$initrlastmigration\" -a 0 -eq $puppetdbcreated ]",
    require => [ Exec["createdb initr"], Service["postgresql"] ],
  }
  file { "$rootdir":
    owner => mongrel,
    group => mongrel,
    recurse => true,
    require => Package["initr"],
  }
  file { "$rootdir/config/mongrel_cluster.yml":
    owner => mongrel,
    group => mongrel,
    mode => 644,
    source => "puppet:///modules/common/mongrel_cluster.yml",
    notify => Service["mongrel_cluster"],
    require => Package["mongrel_cluster"],
  }
  file { "/etc/mongrel_cluster/initr.yml":
    ensure => "$rootdir/config/mongrel_cluster.yml",
  }
}
