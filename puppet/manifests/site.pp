# site.pp

# TODO: find a way to handle globals through a module

# Default path
Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

# Default user for files
File {
  owner => "root",
  group => "root"
}

# Manage root's crontab
Cron { user => "root" }

schedule {
  "daily":
    period => daily,
    repeat => 1;
  "nightly":
    range => "2 - 4",
    period => daily,
    repeat => 1;
}


##### TODO: Ingent globals ###########

#Package { schedule => "daily" }

$osavn = "${lsbdistid}${lsbdistrelease_class}"

case $lsbdistid {
  "MandrivaLinux","Mandrakelinux" : { 
     Service { provider => redhat }
     notice("'$fqdn': Service provider for '$lsbdistid'")
  }
}
$ssh = $operatingsystem ? {
  Debian => ssh,
  default => openssh
}
$ssh_service = $operatingsystem ? {
  Debian => ssh,
  default => sshd
}
$ruby = $operatingsystem ? {
  default => ruby
}
$ruby_devel = $operatingsystem ? {
  Debian => "ruby1.8-dev",
  default => ruby-devel
}
$rdoc = $operatingsystem ? {
  Debian => "rdoc1.8",
  Gentoo => undef,
  Fedora => $operatingsystemrelease ? {
    2 => ruby-rdoc,
    5 => ruby-rdoc,
    6 => ruby-rdoc,
    default => rdoc
  },
  CentOS => undef,
  default => ruby-rdoc
}
$cron_service = $operatingsystem ? {
  Debian => cron,
  Gentoo => fcron,
  default => crond
}
$httpd = $operatingsystem ? {
  Debian => apache2,
  Mandriva => apache-base,
  default => httpd
}
$httpd_service = $operatingsystem ? {
  Debian => apache2,
  default => httpd
}
$ssl_module = $operatingsystem ? {
  Debian => $lsbmajdistrelease ? {
    # debian > 5.0 does not have libapache-mod-ssl
    5 => "",
    default => "libapache-mod-ssl"
  },
  Mandriva => "apache-mod_ssl",
  default => "mod_ssl"
}
$httpd_user = $operatingsystem ? {
  Debian => www-data,
  default => apache
}
$httpd_confdir = $operatingsystem ? {
  Debian => "/etc/apache2/conf.d",
  default => "/etc/httpd/conf.d"
}
$httpd_sitedir = $operatingsystem ? {
  Debian => "/etc/apache2/sites-available",
  default => "/etc/httpd/conf.d"
}
$httpd_documentroot = $operatingsystem ? {
  Debian => "/var/www",
  default => "/var/www/html"
}
$httpd_logdir = $operatingsystem ? {
  Debian => "/var/log/apache2",
  default => "/var/log/httpd"
}
$bind = $operatingsystem ? {
  Debian => bind9,
  default => bind
}
$binduser = $operatingsystem ? {
  Debian => bind,
  default => named
}
$bindservice = $operatingsystem ? {
  Debian => bind9,
  default => named
}
$dnsutils = $operatingsystem ? {
  Debian => dnsutils,
  Gentoo => bind-tools,
  default => bind-utils
}
$manpages = $operatingsystem ? {
  Debian => manpages,
  default => man
}
$samba_tdb_dir = $operatingsystem ? {
  Fedora => "/var/lib/samba",
  Debian => "/var/lib/samba",
  default => "/var/cache/samba"
}
$yum_priorities_plugin = $lsbdistid ? {
  "CentOS" => $lsbdistrelease_class ? {
    "5"     => "yum-priorities",
    "5_2"   => "yum-priorities",
    "5_3"   => "yum-priorities",
    default => "yum-plugin-priorities"
  },
  default => undef
}
$postgres = $operatingsystem ? {
  "Debian" => "postgresql",
  "Gentoo" => "postgresql",
  default => "postgresql-server"
}
$postgres_service = $operatingsystem ? {
  "Debian" => "postgresql-8.3",
  default => "postgresql"
}
$pg_hba = $operatingsystem ? {
  "Debian" => "/etc/postgresql/8.3/main/pg_hba.conf",
  "Gentoo" => "/home/elf/data/db/pg_hba.conf", #TODO: posar el generic de gentoo, aquest es nomes per ricoh
  default => "/var/lib/pgsql/data/pg_hba.conf"
}
$sqlite = $operatingsystem ? {
  "Debian" => "sqlite3",
  default => "sqlite"
}
$dagrepo_source = $lsbdistid ? {
    "CentOS" => $lsbdistrelease ? {
        "4" => "http://packages.sw.be/rpmforge-release/rpmforge-release-0.3.6-1.el4.rf.$architecture.rpm",
        "5" => "http://packages.sw.be/rpmforge-release/rpmforge-release-0.3.6-1.el5.rf.$architecture.rpm",
        "5.2" => "http://packages.sw.be/rpmforge-release/rpmforge-release-0.3.6-1.el5.rf.$architecture.rpm",
        "5.3" => "http://packages.sw.be/rpmforge-release/rpmforge-release-0.3.6-1.el5.rf.$architecture.rpm",
        default => "http://packages.sw.be/rpmforge-release/rpmforge-release-0.3.6-1.el4.rf.$architecture.rpm",
    },
   "FedoraCore" => $lsbdistrelease ? {
        "4" => "http://apt.sw.be/redhat/el4/en/$architecture/RPMS.dag/rpmforge-release-0.3.6-1.el4.rf.$architecture.rpm",
        default => undef
   },
   default => undef
}
$munin = $operatingsystem ? {
  "Gentoo" => "munin",
  default => "munin-node"
}
$libmcrypt = $operatingsystem ? {
  "Mandriva" => "libmcrypt4-devel",
  "Gentoo" =>   "libmcrypt",
  "Debian" =>   "libmcrypt-dev",
  default =>    "libmcrypt-devel"
}
$smartd_packagename = $operatingsystem ? { 
  Fedora => $lsbdistrelease_class ? {
    "3" => kernel-utils,
    default => smartmontools,
    },
  CentOS => $lsbdistrelease_class ? {
    "5"     => smartmontools,
    "5_2"   => smartmontools,
    "5_3"   => smartmontools,
    default => kernel-utils,
    },
  default => smartmontools,
}

$vim = $operatingsystem ? {
  Debian  => "vim-full",
  Gentoo  => "vim",
  default => "vim-enhanced",
}

$incron_service = $operatingsystem ? {
  Debian => "incron",
  default => "incrond",
}
$exim = $operatingsystem ? {
  Debian => "exim4",
  default => "exim"
}
$ntp = $lsbdistid ? {
  Ubuntu => "ntp-server",
  default => "ntp"
}
$mysqlclient = $operatingsystem ? {
  Debian => "mysql-client",
  default => "mysql"
}
$mysqld = $operatingsystem ? {
  Debian => "mysql",
  default => "mysqld"
}
$mysql_dev = $operatingsystem ? {
  Debian => "libmysqlclient15-dev",
  default => "mysql-devel"
}
$perl_net_dns = $operatingsystem ? {
  Debian => "libnet-dns-perl",
  default => "perl-Net-DNS"
}
$perl_net_ip = $operatingsystem ? {
  Debian => "libnet-ip-perl",
  default => "perl-Net-IP"
}
$perl_geo_ipfree = $operatingsystem ? {
  Debian => "libgeo-ipfree-perl",
  default => "perl-Geo-IPfree"
}
$perl_net_xwhois = $operatingsystem ? {
  Debian => "libnet-xwhois-perl",
  default => "perl-Net-XWhois"
}
$ruby_shadow = $operatingsystem ? {
  Debian => "libshadow-ruby1.8",
  default => "ruby-shadow"
}
$php_gd = $operatingsystem ? {
  Debian => "php5-gd",
  default => "php-gd"
}
$nologin = $operatingsystem ? {
  Debian => "/usr/sbin/nologin",
  default => "/sbin/nologin"
}
$vsftpd_conf_file = $operatingsystem ? {
  Debian => "/etc/vsftpd.conf",
  default => "/etc/vsftpd/vsftpd.conf"
}
