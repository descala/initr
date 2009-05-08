class PuppetSchema < ActiveRecord::Migration
  # try to load puppetmaster schema, if it is already
  # loaded continue silently
  def self.up
    # Connect to puppet database
    puppetdb="puppet_#{RAILS_ENV}"
    ActiveRecord::Base.establish_connection puppetdb

    begin
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
      add_index :resources, :host_id, :integer => true
      add_index :resources, :source_file_id, :integer => true

      # Thanks, mysql!  MySQL requires a length on indexes in text fields.
      # So, we provide them for mysql and handle everything else specially.
      if ActiveRecord::Base.configurations[puppetdb]["adapter"] == "mysql"
        execute "CREATE INDEX typentitle ON resources (restype,title(50));"
      else
        add_index :resources, [:title, :restype]
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
      add_index :resource_tags, :resource_id, :integer => true
      add_index :resource_tags, :puppet_tag_id, :integer => true

      create_table :puppet_tags do |t| 
        t.column :name, :string
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :puppet_tags, :id, :integer => true

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

      create_table :param_values do |t|
        t.column :value,  :text, :null => false
        t.column :param_name_id, :integer, :null => false
        t.column :line, :integer
        t.column :resource_id, :integer
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :param_values, :param_name_id, :integer => true
      add_index :param_values, :resource_id, :integer => true

      create_table :param_names do |t| 
        t.column :name, :string, :null => false
        t.column :updated_at, :datetime
        t.column :created_at, :datetime
      end
      add_index :param_names, :name

    rescue
      puts "\nPuppet database already contains tables\n"
    ensure
      # return connection to initr database
      ActiveRecord::Base.establish_connection "#{RAILS_ENV}"
    end
  end

  def self.down
  end
end
