require 'facter'

# fqdn without dots, to write an specific class for each node
Facter.add("fqdnclass") do
  setcode do
    Facter["fqdn"].value.split('.').join('_') rescue "there_is_no_fqdn"
  end
end

# lsbdistrelease without dots, to write an specific class for each node
Facter.add("lsbdistrelease_class") do
  setcode do
    Facter["lsbdistrelease"].value.split('.').join('_') unless Facter["lsbdistrelease"].nil?
  end
end

# TODO
# Dirty patch to let manifests who use the fqdn fact work
# when there is no domain name defined in the node
#Facter.add("fqdn") do
#  setcode do
#    if Facter["fqdn"]
#      Facter["fqdn"].value
#    else
#      "#{Facter["hostname"].value}.#{Facter["uniqueid"].value}"
#    end
#  end
#end
