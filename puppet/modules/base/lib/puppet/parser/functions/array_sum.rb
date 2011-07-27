# substract an array from another
module Puppet::Parser::Functions
   newfunction(:array_sum, :type => :rvalue) do |args|
     args[0] = [ args[0] ] if args[0].class == String
     args[1] = [ args[1] ] if args[1].class == String
     args[0] + args[1]
   end
end
