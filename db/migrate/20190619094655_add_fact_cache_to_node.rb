class AddFactCacheToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :fqdn, :string
    add_column :nodes, :lsbdistid, :string, limit: 30
    add_column :nodes, :lsbdistrelease, :string, limit: 30
    add_column :nodes, :kernelrelease, :string, limit: 40
    add_column :nodes, :puppetversion, :string, limit: 10
    Initr::NodeInstance.find_each do |n|
      n.update_fact_cache
    end
  end

  def self.down
    remove_column :nodes, :fqdn
    remove_column :nodes, :lsbdistid
    remove_column :nodes, :lsbdistrelease
    remove_column :nodes, :kernelrelease
    remove_column :nodes, :puppetversion
  end
end
