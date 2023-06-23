class AddRsyncdPasswordColumn < ActiveRecord::Migration

  def self.up
    add_column :copies, :rsyncd_password, :string
  end

  def self.down
    remove_column :copies, :rsyncd_password
  end

end

