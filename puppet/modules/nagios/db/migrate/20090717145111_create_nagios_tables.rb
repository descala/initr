class CreateNagiosTables < ActiveRecord::Migration

  def self.up
    create_table :initr_nagios_checks do |t|
      t.integer :initr_nagios_id
      t.string :name
      t.string :command
      t.boolean :check_freshness
      t.string :freshness
      t.string :minute
      t.string :hour
      t.string :ensure
      t.boolean :notifications_enabled
      t.timestamps null: false
    end
  end

  def self.down
    drop_table :initr_nagios_checks
  end

end

