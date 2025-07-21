class CreateBindZonesTable < ActiveRecord::Migration[5.2]

  def self.up
    create_table :bind_zones do |t|
      t.string :domain
      t.text :zone
      t.integer :bind_id
      t.timestamps
    end
  rescue
    nil
  end

  def self.down
    drop_table :bind_zones
  end

end

