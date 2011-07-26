class AddIndexesToKlasses < ActiveRecord::Migration
  def self.up
    add_index :klasses, [:node_id, :type]
  end
  
  def self.down
    remove_index :klasses, :column => [:node_id, :type]
  end
end
