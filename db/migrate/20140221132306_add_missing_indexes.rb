class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :nodes, :provider_id
    add_index :nodes, :type
    add_index :nodes, :user_id
    add_index :nodes, :name
    add_index :klasses, :type
    add_index :klasses, :klass_id
    add_index :klasses, :active
  end
  
  def self.down
    remove_index :nodes, :provider_id
    remove_index :nodes, :type
    remove_index :nodes, :user_id
    remove_index :nodes, :name
    remove_index :klasses, :type
    remove_index :klasses, :klass_id
    remove_index :klasses, :active
  end
end
