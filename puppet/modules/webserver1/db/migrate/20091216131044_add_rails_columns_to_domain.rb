class AddRailsColumnsToDomain < ActiveRecord::Migration

  def self.up
    add_column :webserver1_domains, :railsapp,   :boolean
    add_column :webserver1_domains, :rails_root, :string
    add_column :webserver1_domains, :rails_spawn_method, :string
  end

  def self.down
    remove_column :webserver1_domains, :railsapp
    remove_column :webserver1_domains, :rails_root
    remove_column :webserver1_domains, :rails_spawn_method
  end

end
