define remotefile($owner = root, $server = 'one.ingent.net', $group = root, $mode, $source, $backup = false, $recurse = false, $ensure = '') {
  case $ensure {
    "absent": {
        file { $name: ensure => absent }
    }

    default: {
      file { $name:
        mode => $mode,
        owner => $owner,
        group => $group,
        backup => $backup,
        recurse => $recurse,
        source => "puppet://$server/dist/$source",
      }
    }
  }
}

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
        exec { "/bin/grep -v -Fx \"$line\" $file > /tmp/puppettmpfile; /bin/cat /tmp/puppettmpfile > $file ; rm /tmp/puppettmpfile":
                path => "/bin:/usr/bin:/usr/sbin",
                onlyif => "/bin/grep -Fx \"$line\" '$file'",
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

