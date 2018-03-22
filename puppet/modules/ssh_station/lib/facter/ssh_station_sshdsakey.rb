require 'facter'

Facter.add("ssh_station_sshdsakey") do

  setcode do
    pub_key = ""
    pub_key_file = "/home/ssh_station/.ssh/id_dsa.pub"
    if File.exists?(pub_key_file) and File.readable?(pub_key_file)
      pub_key = open(pub_key_file) {|f| f.read }
    end
    pub_key
  end

end
