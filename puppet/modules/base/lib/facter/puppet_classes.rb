require 'facter'

# Puppet classes currently applied
Facter.add("puppet_classes") do
  setcode do
    if File.exist?("/var/cache/puppet/state/classes.txt")
      path = "/var/cache/puppet/state/classes.txt"
    else
      path = "/var/lib/puppet/state/classes.txt"
    end
    open(path).read.split("\n").sort.join(" ") if File.file?(path)
  end
end
