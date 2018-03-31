require 'facter'

begin
  Dir.entries("/home/ssh_station_operators").each do |dir|
    next unless dir =~ /^initr_.+/
      Facter.add("#{dir}_operator_key") do
        setcode do
          path = "/home/ssh_station_operators/#{dir}/.ssh/id_rsa.pub"
          open(path).read if File.file?(path)
        end
      end
  end
rescue
end
