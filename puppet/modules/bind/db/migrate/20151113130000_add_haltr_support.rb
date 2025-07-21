class AddHaltrSupport < ActiveRecord::Migration[5.2]

  def change
    add_column :bind_zones, :info, :text
    add_column :bind_zones, :invoice_line_id, :integer
    add_column :bind_zones, :active_ns, :string
    # registry info:
    add_column :bind_zones, :registrant, :string
    add_column :bind_zones, :expires_on, :date
  end

end
