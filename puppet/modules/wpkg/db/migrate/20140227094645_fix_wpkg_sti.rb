class FixWpkgSti < ActiveRecord::Migration

  def self.up
    execute "update klasses set type='InitrWpkg' where type = 'Initr::InitrWpkg';"
  end

  def self.down
    # will not undo this ...
  end

end
