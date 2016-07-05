class AddWhoisNameServersToBindZones < ActiveRecord::Migration
  def change
    add_column :bind_zones, :whois_ns, :string
  end
end
