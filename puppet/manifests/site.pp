# site.pp
#import "nodes/*"
#import "../modules/common/manifests/functions.pp"

# Usage:
# append_if_no_such_line { dummy_modules:
#       file => "/etc/modules",
#       line => dummy
#       }
#
# Ensures, that the line "line" exists in "file".
define append_if_no_such_line($file, $line) {
        exec { "/bin/echo '$line' >> '$file'":
                unless => "/bin/grep -Fx '$line' '$file'"
        }
}

# Usage:
# delete_lines { suppress_printk:
#    file => "/etc/sysctl.conf",
#    pattern => "^[[:space:]]*kernel[/.]printk[=[:space:]]+",
# }
#
define delete_lines($file, $pattern) {
   exec { "sed -i -r -e '/$pattern/d' $file":
      onlyif => "/bin/grep -E '$pattern' '$file'",
   }
}



# Usage:
# delete_if_such_lines { dummy_modules:
#       file => "/etc/modules",
#       line => dummy
#       }
#
# Ensures, that the line(s) "line" doesn't exists in "file".
define delete_if_such_lines($file, $line) {
        exec { "/bin/grep -v -Fx '$line' $file > /tmp/puppettmpfile; /bin/cat /tmp/puppettmpfile > $file ; rm /tmp/puppettmpfile":
                path => "/bin:/usr/bin:/usr/sbin",
                onlyif => "/bin/grep -Fx '$line' '$file'",
        }
}

# Usage:
# replace { set_munin_node_port:
#              file => "/etc/munin/munin-node.conf",
#              pattern => "^port (?!$port)[0-9]*",
#              replacement => "port $port"
# }
define replace($file, $pattern, $replacement) {
    $pattern_no_slashes = slash_escape($pattern)
    $replacement_no_slashes = slash_escape($replacement)
    exec { "/usr/bin/perl -pi -e 's/$pattern_no_slashes/$replacement_no_slashes/' '$file'":
        onlyif => "/usr/bin/perl -ne 'BEGIN { \$ret = 1; } \$ret = 0 if /$pattern_no_slashes/; END { exit \$ret; }' '$file'",
        alias => "exec_$name",
    }
}

# Usage:
# line { description:
# 	file => "filename",
# 	line => "content",
# 	ensure => {absent,present}
# }
define line($file, $line, $ensure) {
	case $ensure {
		default : { err ( "unknown ensure value $ensure" ) }
		present: {
			exec { "/bin/echo '$line' >> '$file'":
				unless => "/bin/grep -Fx '$line' '$file'"
			}
		}
		absent: {
			exec { "/usr/bin/perl -ni -e 'print unless /^\\Q$line\\E$/' '$file'":
				onlyif => "/bin/grep -Fx '$line' '$file'"
			}
		}
	}
}

# create a file from snippets
# stored in a directory
#
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# TODO:
# * get rid of the $dir parameter
# * create the directory in _part too

# Usage:
# concatenated_file { "/etc/some.conf":
# 	dir => "/etc/some.conf.d",
# }
# Use Exec["concat_$name"] as Semaphor
define concatenated_file (
	$dir, $mode = 0644, $owner = root, $group = root 
	)
{
	file {
		$dir:
			ensure => directory, checksum => mtime,
			## This doesn't work as expected
			#recurse => true, purge => true, noop => true,
			mode => $mode, owner => $owner, group => $group;
		$name:
			ensure => present, checksum => md5,
			mode => $mode, owner => $owner, group => $group;
	}

	exec { "find ${dir} -maxdepth 1 -type f ! -name '*puppettmp' -print0 | sort -z | xargs -0 cat > ${name}":
		refreshonly => true,
		subscribe => File[$dir],
		alias => "concat_${name}",
	}
}


# Add a snippet called $name to the concatenated_file at $dir.
# The file can be referenced as File["cf_part_${name}"]
define concatenated_file_part (
	$dir, $content = '', $ensure = present,
	$mode = 0644, $owner = root, $group = root 
	)
{

	file { "${dir}/${name}":
		ensure => $ensure, content => $content,
		mode => $mode, owner => $owner, group => $group,
		alias => "cf_part_${name}",
	}

}

# put a config file with default permissions
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.

# Usage:
# config_file { filename:
# 	content => "....\n",
# }
define config_file ($content) {
	file { $name:
		content => $content,
		# keep old versions on the server
		backup => server,
		# default permissions for config files
		mode => 0644, owner => root, group => root,
		# really detect changes to this file
		checksum => md5,
	}
}

# TODO: find a way to handle globals through a module

# Default path
Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }

# Default user for files
File {
  owner => "root",
  group => "root"
}

# Manage root's crontab
# absent values are a workaround for bug http://projects.puppetlabs.com/issues/4528#note-5
#Cron {
#  user => "root",
#  minute => absent,
#  hour => absent,
#  monthday => absent,
#  month => absent,
#  weekday => absent,
#}

# Do not change Nagios definitions too often
Nagios_host {
  schedule => daily,
  }
Nagios_service {
  schedule => daily,
}

schedule {
  "daily":
    period => daily,
    repeat => 1;
  "nightly":
    range => "2 - 6",
    period => daily,
    repeat => 1;
}


Package { schedule => "daily" }

$osavn = "${lsbdistid}${lsbdistrelease_class}"

case $lsbdistid {
  "MandrivaLinux","Mandrakelinux" : { 
     Service { provider => redhat }
     notice("'$fqdn': Service provider for '$lsbdistid'")
  }
}

$p7zip_package = $operatingsystem ? {
  /Debian|Ubuntu/ => p7zip-full,
  default => p7zip
}

$ssh_package = $operatingsystem ? {
  /Debian|Ubuntu/ => ssh,
  default => openssh
}
$ssh_service = $operatingsystem ? {
  /Debian|Ubuntu/ => ssh,
  default => sshd
}
$ruby_devel = $operatingsystem ? {
  /Debian|Ubuntu/ => "ruby-dev",
  default => ruby-devel
}
$rdoc = $operatingsystem ? {
  /Debian|Ubuntu/ => "rdoc",
  /Gentoo/ => undef,
  /Fedora/ => $operatingsystemrelease ? {
    "2" => ruby-rdoc,
    "5" => ruby-rdoc,
    "6" => ruby-rdoc,
    default => rdoc
  },
  /CentOS/ => undef,
  default => ruby-rdoc
}
$cron_service = $operatingsystem ? {
  /Debian|Ubuntu/ => cron,
  /Gentoo/ => fcron,
  default => crond
}
$httpd = $operatingsystem ? {
  /Debian|Ubuntu/ => apache2,
  /Mandriva/ => apache-base,
  default => httpd
}
$httpd_service = $operatingsystem ? {
  /Debian|Ubuntu/ => apache2,
  default => httpd
}
$ssl_module = $operatingsystem ? {
  "Debian" => $lsbmajdistrelease ? {
    # debian > 5.0 does not have libapache-mod-ssl
    "4" => "libapache-mod-ssl",
    default => ""
  },
  # TODO ubuntu > 7.4 does not have libapache-mod-ssl
  "Ubuntu" => "",
  "Mandriva" => "apache-mod_ssl",
  default => "mod_ssl"
}
$httpd_user = $operatingsystem ? {
  /Debian|Ubuntu/ => www-data,
  default => apache
}
$httpd_confdir = $operatingsystem ? {
  "Debian" => $lsbmajdistrelease ? {
    "8"       => "/etc/apache2/conf-available",
    default => "/etc/apache2/conf.d"
  },
  default => "/etc/httpd/conf.d"
}
$httpd_sitedir = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/apache2/sites-available",
  default => "/etc/httpd/conf.d"
}
$httpd_conffile = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/apache2/apache2.conf",
  default => "/etc/httpd/conf/httpd.conf"
}
$httpd_documentroot = $operatingsystem ? {
  /Debian|Ubuntu/ => "/var/www",
  default => "/var/www/html"
}
$httpd_logdir = $operatingsystem ? {
  /Debian|Ubuntu/ => "/var/log/apache2",
  default => "/var/log/httpd"
}
$dnsutils = $operatingsystem ? {
  /Debian|Ubuntu/ => dnsutils,
  /Gentoo/ => bind-tools,
  default => bind-utils
}
$manpages = $operatingsystem ? {
  /Debian|Ubuntu/ => 'manpages',
  /Fedora/        => $lsbmajdistrelease ? {
    15      => 'man-pages',
    default => 'man'
  },
  default         => 'man'
}
$samba_tdb_dir = $operatingsystem ? {
  "Fedora" => "/var/lib/samba",
  /Debian|Ubuntu/ => "/var/lib/samba",
  default => "/var/cache/samba"
}
$samba_service = $operatingsystem ? {
  'Debian' => $lsbmajdistrelease ? {
    '9' => 'smbd',
    default => 'samba'
  },
  default => 'samba'
}
$smbclient = $operatingsystem ? {
  "CentOS" => "samba-client",
  default => "smbclient"
}
$yum_priorities_plugin = $lsbdistid ? {
  "CentOS" => $lsbmajdistrelease ? {
    "5"     => "yum-priorities",
    default => "yum-plugin-priorities"
  },
  default => undef
}
$postgres = $operatingsystem ? {
  /Debian|Ubuntu/ => "postgresql",
  "Gentoo" => "postgresql",
  default => "postgresql-server"
}
$postgres_service = $operatingsystem ? {
  /Debian|Ubuntu/ => $lsbmajdistrelease ? {
    "5"     => "postgresql-8.3",
    default => "postgresql"
  },
  default => "postgresql"
}
$sqlite = $operatingsystem ? {
  /Debian|Ubuntu/ => "sqlite3",
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
$munin_html_dir = $operatingsystem ? {
  /Debian|Ubuntu/ => "/var/www/html/munin", #TODO: check this
  default => "/var/www/html/munin"
}
$libmcrypt = $operatingsystem ? {
  "Mandriva" => "libmcrypt4-devel",
  "Gentoo" =>   "libmcrypt",
  /Debian|Ubuntu/ =>   "libmcrypt-dev",
  default => undef
}
$smartd_packagename = $operatingsystem ? { 
  "Fedora" => $lsbdistrelease_class ? {
    "3" => kernel-utils,
    default => smartmontools,
    },
  "CentOS"=> $lsbdistrelease_class ? {
    "5"     => smartmontools,    "5_2"   => smartmontools,
    "5_2"   => smartmontools,
    "5_3"   => smartmontools,
    "5_4"   => smartmontools,
    default => kernel-utils,
    },
  default => smartmontools,
}

$smartd_service = $operatingsystem ? {
  /Debian|Ubuntu/ => 'smartmontools',
  default         => 'smartd',
}

$vim = $operatingsystem ? {
  /Debian|Ubuntu/  => "vim-nox",
  /Gentoo/  => "vim",
  default => "vim-enhanced",
}

$incron_service = $operatingsystem ? {
  /Debian|Ubuntu/ => "incron",
  default => "incrond",
}
$exim = $operatingsystem ? {
  /Debian|Ubuntu/ => "exim4",
  default => "exim"
}
$ntp = $lsbdistid ? {
  "Ubuntu" => "ntp-server",
  default => "ntp"
}
$squid_user = $operatingsystem ? {
  /Debian|Ubuntu/ => "proxy",
  default => "squid"
}
$ldap = $operatingsystem ? {
  /Debian|Ubuntu/ => "slapd",
  default => "openldap"
}
$ldap_service = $operatingsystem ? {
  /Debian|Ubuntu/ => "slapd",
  default => "ldap"
}
$ldap_conf_file = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/ldap/slapd.conf",
  default => "/etc/openldap/slapd.conf"
}
$ldap_user = $operatingsystem ? {
  /Debian|Ubuntu/ => "openldap",
  default => "ldap"
}
$mysqlclient = $operatingsystem ? {
  /Debian|Ubuntu/ => "mysql-client",
  default => "mysql"
}
$mysqld = $operatingsystem ? {
  /Debian|Ubuntu/ => "mysql",
  default => "mysqld"
}
$mysql_dev = $operatingsystem ? {
  'Ubuntu' => 'libmysqlclient-dev',
  'Debian' => $lsbmajdistrelease ? {
    '9' => 'libmariadbclient-dev',
    default => 'libmysqlclient-dev'
  },
  default => 'mysql-devel'
}
$perl_net_dns = $operatingsystem ? {
  /Debian|Ubuntu/ => "libnet-dns-perl",
  default => "perl-Net-DNS"
}
$perl_net_ip = $operatingsystem ? {
  /Debian|Ubuntu/ => "libnet-ip-perl",
  default => "perl-Net-IP"
}
$perl_geo_ipfree = $operatingsystem ? {
  /Debian|Ubuntu/ => "libgeo-ipfree-perl",
  "CentOS" => $lsbdistrelease_class ? {
    "4_6"     => "perl-Geo-IP",
    "4_7"     => "perl-Geo-IP",
    "4_8"     => "perl-Geo-IP",
    "4_9"     => "perl-Geo-IP",
    default => "perl-Geo-IPfree"
    },
 default => "perl-Geo-IPfree"
}
$perl_net_xwhois = $operatingsystem ? {
  /Debian|Ubuntu/ => "libnet-xwhois-perl",
  default => "perl-Net-XWhois"
}
$ruby_shadow = $operatingsystem ? {
  "Ubuntu" => 'libshadow-ruby1.8',
  "Debian" => $lsbmajdistrelease ? {
    '6'     => 'libshadow-ruby1.8',
    default => 'ruby-shadow'
  },
  default => 'ruby-shadow'
}
$php_gd = $operatingsystem ? {
  /Debian|Ubuntu/ => "php5-gd",
  default => "php-gd"
}
$nologin = $operatingsystem ? {
  /Debian|Ubuntu/ => "/usr/sbin/nologin",
  default => "/sbin/nologin"
}
$vsftpd_conf_file = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/vsftpd.conf",
  default => "/etc/vsftpd/vsftpd.conf"
}
$nagios_plugins_dir = $operatingsystem ? {
  /Debian|Ubuntu/ => $lsbdistcodename ? {
    dapper => "/usr/local/nagios/libexec",
    default => "/usr/lib/nagios/plugins"
  },
  default => "/usr/local/nagios/libexec"
}
$nagios_group = $operatingsystem ? {
  /Debian|Ubuntu/ => "nagios",
  default => "nagcmd"
}
$send_nsca = $operatingsystem ? {
  /Debian|Ubuntu/ => "/usr/sbin/send_nsca",
  default => "/usr/local/nsca/bin/send_nsca"
}
$send_nsca_cfg = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/send_nsca.cfg",
  default => "/usr/local/nsca/etc/send_nsca.cfg"
}
$monitrc = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/monit/monitrc",
  default => ["/etc/monit.conf", "/etc/monitrc"]
}
$monit_d = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/monit/monitrc.d",
  default         => "/etc/monit.d"
}
$dhcp_package = $operatingsystem ? {
  "Debian" => "isc-dhcp-server",
  "Ubuntu" => "dhcp3-server",
  default => "dhcp"
}
$dhcp_service = $operatingsystem ? {
  "Debian" => "isc-dhcp-server",
  "Ubuntu" => "dhcp3-server",
  default => "dhcpd"
}
$dhcp_conf = $operatingsystem ? {
  /Debian|Ubuntu/ => "/etc/dhcp/dhcpd.conf",
  default => "/etc/dhcpd.conf"
}
$ddclient_user = $operatingsystem ? {
  "Centos" => ddclient,
  default => root
}
$ca_certificates = $operatingsystem ? {
  "Centos" => "openssl",
  default => "ca-certificates"
}
$openvpn_easyrsa = $operatingsystem ? {
  "Centos" => "/usr/share/openvpn/easy-rsa/2.0",
  default => "/usr/share/doc/openvpn/examples/easy-rsa/2.0"
}
$lha = $operatingsystem ? {
  "Debian" => $lsbmajdistrelease ? {
    6 => "lha",
    default => "lhasa"
  },
  default => "lhasa"
}
$maillog = $operatingsystem ? {
  "Debian"  => '/var/log/mail.info',
  default => '/var/log/maillog'
}
$php_socket = $operatingsystem ? {
  "Debian" => $lsbmajdistrelease ? {
    '9' => "/var/run/php/php7.0-fpm.sock",
    default => "/var/run/php5-fpm.sock"
  },
  default => "/var/run/php5-fpm.sock"
}
$nagios_plugins_basic = $operatingsystem ? {
  'Debian' => $lsbmajdistrelease ? {
    '10' => 'monitoring-plugins-basic',
    default => 'nagios-plugins-basic'
  },
  default => 'nagios-plugins-basic'
}
$nagios_plugins_standard= $operatingsystem ? {
  'Debian' => $lsbmajdistrelease ? {
    '10' => 'monitoring-plugins-standard',
    default => 'nagios-plugins-standard'
  },
  default => 'nagios-plugins-standard'
}
