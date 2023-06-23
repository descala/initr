class ChangeExcludesType < ActiveRecord::Migration

  def self.up
    change_column :copies, :excludes, :text
  end

  def self.down
    change_column :copies, :excludes, :string
  end

end

