class AddIndexesToNodes < ActiveRecord::Migration
  def self.up
    add_index :nodes, [:project_id, :user_id, :provider_id, :type]
  end
  
  def self.down
    remove_index :nodes, :column => [:project_id, :user_id, :provider_id, :type]
  end
end
