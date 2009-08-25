# gsub( string, pattern, replacement )
module Puppet::Parser::Functions
   newfunction(:gsub, :type => :rvalue) do |args|
     regexp = Regexp.new(args[1])
     args[0].gsub(regexp,args[2])
   end
end
