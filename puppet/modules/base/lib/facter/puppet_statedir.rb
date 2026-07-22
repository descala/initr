require 'facter'

# Real puppet statedir for this agent (new /var/cache vs legacy /var/lib)
Facter.add("puppet_statedir") do
  setcode do
    ['/var/cache/puppet/state', '/var/lib/puppet/state'].find { |d|
      File.exist?(File.join(d, 'state.yaml'))
    } || '/var/cache/puppet/state'   # sane default for a fresh node
  end
end
