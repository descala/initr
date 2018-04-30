## downcase("VALUE")
module Puppet::Parser::Functions
  newfunction(:downcase, :type => :rvalue) do |args|
    args[0].to_s.downcase
  end
end
