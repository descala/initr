class AddHaltrSupport < ActiveRecord::Migration

  def change
    add_column :bind_zones, :info, :string
    add_column :bind_zones, :invoice_line_id, :integer
  end

end
