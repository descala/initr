class AddKlassIdToKlasses < ActiveRecord::Migration

  def self.up
    add_column :klasses, :klass_id, :integer
  end

  def self.down
    remove_column :klasses, :klass_id
  end

end
