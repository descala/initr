class AddReportFieldsToNodes < ActiveRecord::Migration

  def self.up
    add_column :nodes, :last_report, :datetime
    add_column :nodes, :puppet_status, :integer, {:default=>0, :null=>false}
  end

  def self.down
    remove_column :nodes, :last_report
    remove_column :nodes, :puppet_status
  end

end
