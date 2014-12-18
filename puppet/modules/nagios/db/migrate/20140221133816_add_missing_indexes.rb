class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :nagios_checks, :nagios_id
  end
  
  def self.down
    remove_index :nagios_checks, :nagios_id
  end
end
