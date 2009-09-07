require 'facter'

Facter.add("rubygems_version") do
  setcode do
    Gem::VERSION
  end
end
