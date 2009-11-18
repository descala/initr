class AddWebBackupsServerToDomains < ActiveRecord::Migration

  def self.up
    add_column :webserver1_domains, :web_backups_server, :string
  end

  def self.down
    remove_column :webserver1_domains, :web_backups_server
  end

end
