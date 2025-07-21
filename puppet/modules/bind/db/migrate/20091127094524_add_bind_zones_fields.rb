class AddBindZonesFields < ActiveRecord::Migration[5.2]

  def self.up
    add_column :bind_zones, :ttl, :string
    add_column :bind_zones, :serial, :string
  rescue
    nil
  end

  def self.down
    remove_column :bind_zones, :ttl
    remove_column :bind_zones, :serial
  end

end

