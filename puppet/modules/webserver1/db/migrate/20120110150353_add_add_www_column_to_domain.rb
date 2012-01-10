class AddAddWwwColumnToDomain < ActiveRecord::Migration

  def self.up
    add_column :webserver1_domains, :add_www, :boolean, :default => true
  end

  def self.down
    remove_column :webserver1_domains, :add_www
  end

end
