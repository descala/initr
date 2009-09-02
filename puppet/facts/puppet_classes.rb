require 'facter'

# Puppet classes currently applied
Facter.add("puppet_classes") do
  setcode do
    path = "/var/lib/puppet/state/classes.txt"
    open(path).read.split("\n").sort.join(" ") if File.file?(path)
  end
end
