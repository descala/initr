class AddActiveToKlasses < ActiveRecord::Migration

  def self.up
    add_column :klasses, :active, :boolean, :default => true
  end

  def self.down
    remove_column :klasses, :active
  end

end
