require 'facter'

Facter.add("munin_graphs") do

  setcode do
    begin
      (Dir.entries("/etc/munin/plugins") - ["..", "."]).join(",")
    rescue
      ""
    end
  end

end
