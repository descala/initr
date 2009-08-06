require 'facter'

Facter.add("rubygems_path") do
  setcode do
    %x{gem environment gempath}.chomp
  end
end

