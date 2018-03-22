class AddNameToStationPorts < ActiveRecord::Migration

  def self.up
    add_column :initr_ssh_station_ports, :name, :string
  end

  def self.down
    remove_column :initr_ssh_station_ports, :name
  end

end

