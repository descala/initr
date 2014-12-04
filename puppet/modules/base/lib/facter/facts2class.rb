require 'facter'

# fqdn without dots, to write an specific class for each node
Facter.add("fqdnclass") do
  setcode do
    Facter["fqdn"].value.split('.').join('_')
  end
end

# lsbdistrelease without dots, to write an specific class for each node
Facter.add("lsbdistrelease_class") do
  setcode do
    Facter["lsbdistrelease"].value.split('.').join('_') unless Facter["lsbdistrelease"].nil?
  end
end
