class AddAllowOverrideToDomains < ActiveRecord::Migration
  def self.up
    add_column :webserver1_domains, :allow_override, :string, default: 'None'
  end

  def self.down
    remove_column :webserver1_domains, :allow_override
  end
end
