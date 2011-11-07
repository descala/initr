class AddUseSuphpToDomain < ActiveRecord::Migration

  def self.up
    add_column :webserver1_domains, :use_suphp, :boolean, :default => false
  end

  def self.down
    remove_column :webserver1_domains, :use_suphp
  end

end
