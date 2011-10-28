class AddMasterOrSlaveInfoToZones < ActiveRecord::Migration

  def self.up
    add_column :bind_zones, :master, :boolean, :default => true
    add_column :bind_zones, :config, :text
    create_table :bind_masters_slaves, :id => false do |t|
      t.integer :master_id
      t.integer :slave_id
    end
  end

  def self.down
    remove_column :bind_zones, :master
    remove_column :bind_zones, :text
    drop_table :bind_masters_slaves
  end

end

