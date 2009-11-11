class OnePasswordForEachService < ActiveRecord::Migration

  def self.up
    rename_column(:initr_webserver1_domains, :password, :password_ftp)
    rename_column(:initr_webserver1_domains, :password_clear, :password_db)
    add_column(:initr_webserver1_domains, :password_awstats, :string)
  end

  def self.down
    rename_column(:initr_webserver1_domains, :password_ftp, :password)
    rename_column(:initr_webserver1_domains, :password_db, :password_clear)
    remove_column(:initr_webserver1_domains, :password_awstats)
  end

end
