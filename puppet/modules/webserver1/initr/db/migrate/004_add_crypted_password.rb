class AddCryptedPassword < ActiveRecord::Migration

  def self.up
    add_column :initr_webserver1_domains, :crypted_password, :string
  end

  def self.down
    remove_column :initr_webserver1_domains, :crypted_password
  end

end

