class AddHaltrSupport < ActiveRecord::Migration

  def change
    add_column :bind_zones, :info, :string
    add_column :bind_zones, :invoice_line_id, :integer
    add_column :bind_zones, :active_ns, :text
    # registry info:
    add_column :bind_zones, :registrant, :text
    add_column :bind_zones, :expires_on, :date
  end

end
