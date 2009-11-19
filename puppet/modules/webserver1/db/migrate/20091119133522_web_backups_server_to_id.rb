class WebBackupsServerToId < ActiveRecord::Migration

  def self.up
    remove_column :webserver1_domains, :web_backups_server
    add_column :webserver1_domains, :web_backups_server_id, :integer
  end

  def self.down
    add_column :webserver1_domains, :web_backups_server, :string
    remove_column :webserver1_domains, :web_backups_server_id
  end

end
