# check if an array includes a value
module Puppet::Parser::Functions
   newfunction(:array_includes, :type => :rvalue) do |args|
     args[0] = [ args[0] ] if args[0].class != Array
     args[0].include? args[1]
   end
end
