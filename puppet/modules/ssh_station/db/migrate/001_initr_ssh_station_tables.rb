class InitrSshStationTables < ActiveRecord::Migration

  def self.up
    create_table :initr_ssh_station_ports do |t|
      t.integer "num", :null => false
      t.integer "service", :null => false
      t.integer "initr_ssh_station_id"
    end
  end

  def self.down
    drop_table :initr_ssh_station_ports
  end

end

