class CreateCustomKlassConfs < ActiveRecord::Migration

  def self.up
    create_table :custom_klass_confs do |t|
      t.integer :custom_klass_id
      t.string :name
      t.string :value
    end
  end

  def self.down
    drop_table :custom_klass_confs
  end

end

