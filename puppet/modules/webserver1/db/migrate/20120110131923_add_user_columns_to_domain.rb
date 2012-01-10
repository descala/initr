class AddUserColumnsToDomain < ActiveRecord::Migration

  def self.up
    rename_column :webserver1_domains, :username, :user_ftp
    add_column :webserver1_domains, :user_awstats, :string
    add_column :webserver1_domains, :user_mysql, :string
    Initr::Webserver1Domain.all.each do |d|
      d.user_awstats = d.user_ftp
      d.user_mysql   = d.user_ftp
      d.save(false)
    end
  end

  def self.down
    rename_column :webserver1_domains, :user_ftp, :username
    remove_column :webserver1_domains, :user_awstats
    remove_column :webserver1_domains, :user_mysql
  end

end
