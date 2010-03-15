class AddUserRelationToNode < ActiveRecord::Migration

  def self.up
    add_column :nodes, :user_id, :integer
  end

  def self.down
    remove_column :nodes, :user_id
  end

end
