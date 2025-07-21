class AddWhoisNameServersToBindZones < ActiveRecord::Migration[5.2]
  def change
    add_column :bind_zones, :whois_ns, :string
  end
end
