class ChangeCopyKlassToLinkKlass < ActiveRecord::Migration

  def self.up
    Initr::Klass.where("type='CopyKlass'").update_all("type = 'LinkKlass'")
  end

  def self.down
    Initr::Klass.where("type='LinkKlass'").update_all("type = 'CopyKlass'")
  end

end
