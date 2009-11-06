class RemoveDelayedJobs < ActiveRecord::Migration

  def self.up
    drop_table :delayed_jobs
  end

  def self.down
    create_table :delayed_jobs do |table|
      table.integer  :priority, :default => 0
      table.integer  :attempts, :default => 0
      table.text     :handler
      table.string   :last_error
      table.datetime :run_at
      table.datetime :locked_at
      table.string   :locked_by
      table.datetime :failed_at
      table.timestamps
    end
  end

end
