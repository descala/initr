class CreateHostsAndFacts < ActiveRecord::Migration

  def self.up
    begin
      # migrations picked from puppet
      create_table :hosts do |t|
        t.column :name, :string, :null => false
        t.column :ip, :string
        t.column :environment, :string
        t.column :last_compile, :datetime
        t.column :last_freshcheck, :datetime
        t.column :last_report, :datetime
        #Use updated_at to automatically add timestamp on save.
        t.column :updated_at, :datetime
        t.column :source_file_id, :integer
        t.column :created_at, :datetime
      end
      add_index :hosts, :source_file_id, :integer => true
      add_index :hosts, :name
      create_table :fact_names do |t|
        t.column :name, :string, :null => false
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :fact_names, :name
      create_table :fact_values do |t|
        t.column :value, :text, :null => false
        t.column :fact_name_id, :integer, :null => false
        t.column :host_id, :integer, :null => false
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :fact_values, :fact_name_id, :integer => true
      add_index :fact_values, :host_id, :integer => true
    rescue ActiveRecord::StatementInvalid
      # tables already exist
      puts "--> puppet tables already exist"
    end
  end

  def self.down
    # don't remove puppet tables
  end

end
