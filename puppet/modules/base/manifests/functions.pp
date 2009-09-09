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

#
## Replace a section marked by
## comment_char {BEGIN,END} pattern
## with the given content
## if checksum is set to "none", no resource is defined for the edited file
#define file_splice ($file, $pattern = "PUPPET SECTION", $comment_char = "#", $content = "", $input_file = "", $checksum = md5)
#{
#    case $checksum {
#        "none": {}
#        default: { file { $file: checksum => $checksum } }
#    }
#
#    # the splice command needs at least the BEGIN line in the file
#    append_if_no_such_line { "seed-$file-$pattern":
#        file => $file,
#        line => "$comment_char BEGIN $pattern",
#        require => File [ $file ],
#    }
#
#    case $content {
#        "": {
#            case $input_file {
#                "": {
#                    fail ("either input_file or content have to be supplied")
#                }
#                default: {
#                    exec{ "/usr/local/bin/file_splice '$input_file' '$comment_char' '$pattern' $file":
#                        require => Append_if_no_such_line [ "seed-$file-$pattern" ],
#                        subscribe => [ File[$input_file], File[$file] ],
#                    }
#                }
#            }
#        }
#        default: {
#            $splice_file = "$splice_dir/$name"
#            file { $splice_file:
#                mode => 0600, owner => root, group => root,
#                content => $content,
#                require => File [ $splice_dir ],
#            }
#
#            exec{ "/usr/local/bin/file_splice '$splice_file' '$comment_char' '$pattern' $file":
#                require => Append_if_no_such_line [ "seed-$file-$pattern" ],
#                subscribe => [ File [ $splice_file ], File[$file] ]
#            }
#        }
#    }
#}
#
#
#
