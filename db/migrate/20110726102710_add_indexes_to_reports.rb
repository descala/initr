class AddIndexesToReports < ActiveRecord::Migration
  def self.up
    add_index :reports, :node_id
  end
  
  def self.down
    remove_index :reports, :node_id
  end
end
