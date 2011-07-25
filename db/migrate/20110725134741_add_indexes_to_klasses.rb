class AddIndexesToKlasses < ActiveRecord::Migration
  def self.up
    add_index :klasses, [:id, :type]
  end
  
  def self.down
    remove_index :klasses, :column => [:id, :type]
  end
end
