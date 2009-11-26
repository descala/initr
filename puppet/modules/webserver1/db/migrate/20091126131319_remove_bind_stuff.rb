class RemoveBindStuff < ActiveRecord::Migration

  def self.up
    remove_column :webserver1_domains, :mail_ip
    remove_column :webserver1_domains, :www_ip
    remove_column :webserver1_domains, :mx_ip
    remove_column :webserver1_domains, :serial
  end

  def self.down
    add_column :webserver1_domains, :mail_ip, :string
    add_column :webserver1_domains, :www_ip, :string
    add_column :webserver1_domains, :mx_ip, :string
    add_column :webserver1_domains, :serial, :decimal, :precision => 11
  end

end
