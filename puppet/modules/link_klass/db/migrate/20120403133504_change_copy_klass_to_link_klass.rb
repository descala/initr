class ChangeCopyKlassToLinkKlass < ActiveRecord::Migration

  def self.up
    Initr::Klass.update_all("type = 'LinkKlass'","type='CopyKlass'")
  end

  def self.down
    Initr::Klass.update_all("type = 'CopyKlass'","type='LinkKlass'")
  end

end
