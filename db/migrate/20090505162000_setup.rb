class Setup < ActiveRecord::Migration

  def self.up

    # Initr tables
    create_table :nodes do |t|
      t.string   :name, :default => "", :null => false
      t.datetime :updated_at
      t.integer  :project_id
      t.string   :type, :limit => 20
      t.string   :provider_id
    end
    
    create_table :klasses do |t|
      t.integer :node_id
      t.integer :klass_name_id
      t.string  :type
      t.text    :config
    end

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

    create_table :conf_names_klass_names, :id => false do |t|
      t.integer :conf_name_id,  :integer
      t.integer :klass_name_id, :integer
    end

    create_table :base_confs do |t|
      t.integer :base_id
      t.string :optshash
      t.timestamps
    end

  end

  def self.down
    # Initr tables
    drop_table :nodes
    drop_table :klasses
    drop_table :klass_names
    drop_table :confs
    drop_table :conf_names
    drop_table :conf_names_klass_names
    drop_table :base_confs
  end

end
