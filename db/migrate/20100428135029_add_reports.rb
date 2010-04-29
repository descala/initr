class AddReports < ActiveRecord::Migration

  def self.up
    create_table :reports do |t|
      t.integer  :node_id, :null => false
      t.text     :log
      t.datetime :reported_at
      t.integer  :status
      t.timestamps
    end
  end

  def self.down
    drop_table :reports
  end

end
