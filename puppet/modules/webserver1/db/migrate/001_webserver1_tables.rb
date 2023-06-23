class Webserver1Tables < ActiveRecord::Migration

  def self.up

    create_table :initr_webserver1_domains do |t|
      t.integer :initr_webserver1_id
      t.integer :serial
      t.string  :name
      t.string  :ns_ip
      t.string  :www_ip
      t.string  :mx_ip
      t.string  :username
      t.string  :password
      t.string  :password_clear
      t.timestamps null: false
    end

  end

  def self.down
    drop_table :initr_webserver1_domains
  end

end

