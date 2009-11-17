class RemoveInitrPrefix < ActiveRecord::Migration

  def self.up
    puts "  Run \"update klasses set type='Webserver1' where type='InitrWebserver1';\" if you has installed webserver"
    rename_table :initr_webserver1_domains, :webserver1_domains
    rename_column :webserver1_domains, :initr_webserver1_id, :webserver1_id
  end

  def self.down
    rename_table :webserver1_domains, :initr_webserver1_domains
    rename_column :initr_webserver1_domains, :webserver1_id, :initr_webserver1_id
  end

end
