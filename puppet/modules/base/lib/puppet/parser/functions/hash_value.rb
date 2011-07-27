# Donat un hash i una clau, retorna el seu valor
# hash_value(hash, key)
module Puppet::Parser::Functions
   newfunction(:hash_value, :type => :rvalue) do |args|
     return nil if args.size != 2
     args[0][args[1]].nil? ? "" : args[0][args[1]]
   end
end
