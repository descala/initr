class AddAwstatsWwwColumnToDomain < ActiveRecord::Migration

  def self.up
    add_column :webserver1_domains, :awstats_www, :boolean, :default => false
  end

  def self.down
    remove_column :webserver1_domains, :awstats_www
  end

end
