class CreateBindZoneManagers < ActiveRecord::Migration[6.1]
  def change
    create_table :bind_zone_managers do |t|
      t.references :bind_zone, null: false, index: false
      t.references :user, null: false
      t.timestamps
    end
    add_index :bind_zone_managers, [:bind_zone_id, :user_id],
      unique: true, name: 'index_bind_zone_managers_on_zone_and_user'
  end
end
