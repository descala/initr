class AddDnssecToBindZones < ActiveRecord::Migration[5.2]
  def change
    add_column :bind_zones, :dnssec, :boolean, default: false, null: false
  end
end