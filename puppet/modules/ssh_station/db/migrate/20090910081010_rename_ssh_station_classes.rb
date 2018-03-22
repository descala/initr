class RenameSshStationClasses < ActiveRecord::Migration
  def self.up
    execute("update klasses set type='SshStation' where type='InitrSshStation';")
    rename_table :initr_ssh_station_ports, :ssh_station_ports
    rename_column :ssh_station_ports, :initr_ssh_station_id, :ssh_station_id
  end

  def self.down
    execute("update klasses set type='InitrSshStation' where type='SshStation';")
    rename_table :ssh_station_ports, :initr_ssh_station_ports
    rename_column :initr_ssh_station_ports, :ssh_station_id, :initr_ssh_station_id
  end
end
