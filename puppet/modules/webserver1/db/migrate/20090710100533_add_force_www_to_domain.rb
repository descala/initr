class AddForceWwwToDomain < ActiveRecord::Migration

  def self.up
    add_column(:initr_webserver1_domains, :force_www, :boolean)
  end

  def self.down
    remove_column(:initr_webserver1_domains, :force_www)
  end

end

