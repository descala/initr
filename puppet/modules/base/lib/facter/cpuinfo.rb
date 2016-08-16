require 'facter'

Facter.add("processor_virtual_support") do

  setcode do
    r = %x{/bin/egrep '^flags.*(vmx|svm)' /proc/cpuinfo --only-matching}.chomp.split.last
    r ? r : "no"
  end

end
