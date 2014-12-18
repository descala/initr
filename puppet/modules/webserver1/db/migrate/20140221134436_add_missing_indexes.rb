class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :webserver1_domains, :webserver1_id
    add_index :webserver1_domains, :name
    add_index :webserver1_domains, :web_backups_server_id
  end
  
  def self.down
    remove_index :webserver1_domains, :webserver1_id
    remove_index :webserver1_domains, :name
    remove_index :webserver1_domains, :web_backups_server_id
  end
end
