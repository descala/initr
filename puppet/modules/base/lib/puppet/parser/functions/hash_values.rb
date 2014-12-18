# Given a Hash, return its values as an array
module Puppet::Parser::Functions
  newfunction(:hash_values, :type=>:rvalue) do |arguments|
    raise(Puppet::ParseError, "hash_values(): Wrong number of arguments " +
          "given (#{arguments.size} for 1)") if arguments.size < 1
    hash = arguments[0]
    unless hash.is_a?(Hash)
      raise(Puppet::ParseError, 'hash_values(): Requires hash to work with')
    end
    result = hash.values
    return result
  end
end
