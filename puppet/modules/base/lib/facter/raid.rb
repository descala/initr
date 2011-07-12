require 'facter'

# http://projects.puppetlabs.com/projects/puppet/wiki/Raid_Fact_Patterns

Facter.add("raidtype") do
  confine :kernel => :linux
  ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
  setcode do
    swraid=false
    raidtype = []
    if FileTest.exists?("/proc/mdstat")
      txt = File.read("/proc/mdstat")
      raidtype.push("software") if txt =~ /^md/i
      swraid = true if txt =~ /^md/i
    end

    lspciexists = system "/bin/bash -c 'which lspci >&/dev//null'"
    if $?.exitstatus == 0
      output = %x{lspci}
      output.each { |s|
        raidtype.push("#{swraid ? ' ' : ''}hardware") if s =~ /RAID/i
      }
    end
    raidtype
  end
end

Facter.add("raidcontroller") do
  confine :kernel => :linux
  ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
  setcode do
    controllers = []
    lspciexists = system "/bin/bash -c 'which lspci >&/dev//null'"
    if $?.exitstatus == 0
      output = %x{lspci}
      output.each {|s|
        controllers.push($1) if s =~ /RAID bus controller: (.*)/
      }
    end
    controllers
  end
end

