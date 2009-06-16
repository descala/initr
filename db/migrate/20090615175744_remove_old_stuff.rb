class RemoveOldStuff < ActiveRecord::Migration

  def self.up
    drop_table :klass_names
    drop_table :confs
    drop_table :conf_names
  end

  def self.down
    create_table :klass_names do |t|
      t.string :name
      t.string :description
    end

    create_table :confs do |t|
      t.string  :value
      t.integer :klass_id
      t.integer :conf_name_id
    end

    create_table :conf_names do |t|
      t.string  :name
      t.text    :help
    end
  end

end

