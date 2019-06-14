class CreateMissingPuppetTables < ActiveRecord::Migration
  def self.up
    begin
      # migrations picked from puppet

      create_table :resources do |t|
        t.column :title, :text, :null => false
        t.column :restype,  :string, :null => false
        t.column :host_id, :integer
        t.column :source_file_id, :integer
        t.column :exported, :boolean
        t.column :line, :integer
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :resources, :host_id
      add_index :resources, :source_file_id

      if ActiveRecord::Base.connection.class != ActiveRecord::ConnectionAdapters::Mysql2Adapter
        add_index :resources, [:title, :restype]
      else
        execute "CREATE INDEX typentitle ON resources (restype,title(50));"
      end

      create_table :source_files do |t|
        t.column :filename, :string
        t.column :path, :string
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :source_files, :filename

      create_table :resource_tags do |t|
        t.column :resource_id, :integer
        t.column :puppet_tag_id, :integer
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :resource_tags, :resource_id
      add_index :resource_tags, :puppet_tag_id

      create_table :puppet_tags do |t|
        t.column :name, :string
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end

      add_index :puppet_tags, :id

      # hosts, fact_names and fact_values ... already created in
      # 20091106141135_create_hosts_and_facts.rb

      create_table :param_values do |t|
        t.column :value,  :text, :null => false
        t.column :param_name_id, :integer, :null => false
        t.column :line, :integer
        t.column :resource_id, :integer
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :param_values, :param_name_id
      add_index :param_values, :resource_id

      create_table :param_names do |t|
        t.column :name, :string, :null => false
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :param_names, :name

      create_table :inventory_nodes do |t|
        t.column :name, :string, :null => false
        t.column :timestamp, :datetime, :null => false
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end

      add_index :inventory_nodes, :name, :unique => true

      create_table :inventory_facts do |t|
        t.column :node_id, :integer, :null => false
        t.column :name, :string, :null => false
        t.column :value, :text, :null => false
      end

      add_index :inventory_facts, [:node_id, :name], :unique => true
    rescue ActiveRecord::StatementInvalid
      # tables already exist
      puts "--> puppet tables already exist"
    end
  end
end
