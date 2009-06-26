class AddShellAndDbName < ActiveRecord::Migration

  def self.up
    add_column :initr_webserver1_domains, :shell,  :string
    add_column :initr_webserver1_domains, :dbname, :string
  end

  def self.down
    remove_column :initr_webserver1_domains, :shell
    remove_column :initr_webserver1_domains, :dbname
  end

end

