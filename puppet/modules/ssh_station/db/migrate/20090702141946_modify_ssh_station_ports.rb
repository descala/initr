class ModifySshStationPorts < ActiveRecord::Migration

  def self.up
    add_column :initr_ssh_station_ports, 'host', :string
    #InitrSshStationPort.all.collect {|p| p.host="localhost" ; p.save }
  end

  def self.down
    remove_column :initr_ssh_station_ports, 'host'
  end

end

