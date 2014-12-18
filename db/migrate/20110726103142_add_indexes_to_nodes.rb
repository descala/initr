class AddIndexesToNodes < ActiveRecord::Migration
  def self.up
    add_index :nodes, :project_id
    add_index :nodes, :user_id
    add_index :nodes, :provider_id
    add_index :nodes, :type
  end
  
  def self.down
    remove_index :nodes, :project_id
    remove_index :nodes, :user_id
    remove_index :nodes, :provider_id
    remove_index :nodes, :type
  end
end
