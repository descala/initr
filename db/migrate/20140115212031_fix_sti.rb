class FixSti < ActiveRecord::Migration

  def self.up
    execute "update nodes set type=concat('Initr::',nodes.type);"
    execute "update klasses set type=concat('Initr::',klasses.type);"
  end

  def self.down
    # will not undo this ...
  end

end
