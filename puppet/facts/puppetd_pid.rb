require 'facter'

# PID del proces puppetd

Facter.add("puppetd_pid") do
	setcode do
			 %x{/sbin/pidof -x puppetd}.chomp
	end
end
