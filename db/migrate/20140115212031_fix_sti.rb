class FixSti < ActiveRecord::Migration

  def self.up
    execute "update nodes set type=concat('Initr::',type) where type not like 'Initr::%';"
    execute "update klasses set type=concat('Initr::',type) where type not like 'Initr::%';"
  end

  def self.down
    # will not undo this ...
  end

end
