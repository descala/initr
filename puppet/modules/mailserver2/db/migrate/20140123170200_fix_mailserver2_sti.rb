class FixMailserver2Sti < ActiveRecord::Migration

  def self.up
    execute "update klasses set type='InitrMailserver2' where type = 'Initr::InitrMailserver2';"
  end

  def self.down
    # will not undo this ...
  end

end
