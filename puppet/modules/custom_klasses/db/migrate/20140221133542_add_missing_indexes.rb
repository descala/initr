class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :custom_klass_confs, :custom_klass_id
  end
  
  def self.down
    remove_index :custom_klass_confs, :custom_klass_id
  end
end
