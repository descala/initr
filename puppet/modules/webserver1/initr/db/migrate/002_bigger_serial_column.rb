class BiggerSerialColumn < ActiveRecord::Migration

  def self.up
    change_column :initr_webserver1_domains, :serial, :decimal, :precision => 11
  end

  def self.down
    change_column :initr_webserver1_domains, :serial, :integer
  end

end

