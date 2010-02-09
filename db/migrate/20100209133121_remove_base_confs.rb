class RemoveBaseConfs < ActiveRecord::Migration

  def self.up
    drop_table :base_confs
  end

  def self.down
    create_table :base_confs do |t|
      t.integer :base_id
      t.string :optshash
      t.timestamps
    end
  end

end
