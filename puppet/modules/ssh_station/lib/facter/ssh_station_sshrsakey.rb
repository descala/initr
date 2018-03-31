require 'facter'

Facter.add("ssh_station_sshrsakey") do

  setcode do
    pub_key = ""
    pub_key_file = "/home/ssh_station/.ssh/id_rsa.pub"
    if File.exists?(pub_key_file) and File.readable?(pub_key_file)
      pub_key = open(pub_key_file) {|f| f.read }
    end
    pub_key
  end

end
