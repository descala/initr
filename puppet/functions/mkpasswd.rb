## mkpasswd("password", "12345678")
# needs an 8-char salt *always*
module Puppet::Parser::Functions
  newfunction(:mkpasswd, :type => :rvalue) do |args|
    %x{/usr/bin/mkpasswd -H MD5 #{args[0]} #{args[1]}}.chomp
  end
end
