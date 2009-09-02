require 'facter'

Facter.add("rubygems_path") do
  setcode do
    %x{gem environment gempath}.chomp
  end
end

Facter.add("rubygems_version") do
    setcode do
        output = %x{gem -v}.chomp
        if output =~ /command not found/
            ""
        else
            output
        end
    end
end
