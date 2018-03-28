class AddEmailColumn < ActiveRecord::Migration

  def self.up
    add_column :copies, :email, :string
  end

  def self.down
    remove_column :copies, :email
  end

end

