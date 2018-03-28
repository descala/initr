class CreateCopiesTable < ActiveRecord::Migration

  def self.up
    create_table :copies do |t|
      t.integer :copier_id
      t.string :name
      t.string :monthday
      t.string :weekday
      t.string :hour
      t.string :minute
      t.integer :warn
      t.integer :crit
      t.string :source
      t.string :destination
      t.string :historic
      t.string :bdays
      t.string :fs
      t.string :excludes
      t.string :options
      t.string :mount_type
      t.string :mount_file_to_check

      t.timestamps
    end
  end

  def self.down
    drop_table :copies
  end

end

