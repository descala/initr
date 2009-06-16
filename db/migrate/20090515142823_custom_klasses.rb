class CustomKlasses < ActiveRecord::Migration

  def self.up
    add_column(:klasses, :name, :string)
    add_column(:klasses, :description, :string)
    remove_column(:klasses, :klass_name_id)
    create_table :custom_klass_confs do |t|
      t.integer :custom_klass_id
      t.string :name
      t.string :value
    end
  end

  def self.down
    remove_column(:klasses, :name)
    remove_column(:klasses, :description)
    add_column(:klasses, :klass_name_id, :integer)
    drop_table :custom_klass_confs
  end

end

# you should do in database:
# update klasses set type="CustomKlass" where type is NULL;

