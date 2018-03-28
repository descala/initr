# localsid.rb -- fetch the local SID from samba
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# Based on abnormaliti's "virtual" fact from
# http://reductivelabs.com/trac/puppet/wiki/VirtualRecipe

Facter.add("localsid") do
	
	ENV["PATH"]="/bin:/sbin:/usr/bin:/usr/sbin"
	
	result = "none"
	
	setcode do
		output = `net getlocalsid`
		if output =~ /^SID for domain [^ ]* is: (.*)\n$/
			$1
		else
			nil
		end
	end
end

