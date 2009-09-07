require 'facter'

Facter.add("rubygems_version") do
  setcode do
    Gem::VERSION rescue nil
  end
end
