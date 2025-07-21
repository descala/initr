class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def self.up
    add_index :bind_zones, :domain
    add_index :bind_zones, :bind_id
    add_index :bind_masters_slaves, :master_id
    add_index :bind_masters_slaves, :slave_id
  rescue
    nil
  end
  
  def self.down
    remove_index :bind_zones, :domain
    remove_index :bind_zones, :bind_id
    remove_index :bind_masters_slaves, :master_id
    remove_index :bind_masters_slaves, :slave_id
  end
end
