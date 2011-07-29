module Puppet::Parser::Functions
   newfunction(:hash, :type => :rvalue) do |args|
     return nil if args.size % 2 != 0
     hash={}
     i=0
     args.each do |v|
       i+=1
       next if i % 2 == 0
       hash[args[i-1]] = args[i]
     end
     return hash
   end
end
