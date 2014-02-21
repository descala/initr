class AddIndexesToKlasses < ActiveRecord::Migration
  def self.up
    add_index :klasses, :node_id
    add_index :klasses, :type
  end
  
  def self.down
    remove_index :klasses, :node_id
    remove_index :klasses, :type
  end
end
