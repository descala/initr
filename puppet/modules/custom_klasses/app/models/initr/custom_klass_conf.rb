class Initr::CustomKlassConf < ActiveRecord::Base

  unloadable

  belongs_to :klass, :class_name => "Initr::CustomKlass"
  validates_presence_of :name, :value
  validates_uniqueness_of :name, :scope => :custom_klass_id

  def <=>(oth)
    self.name <=> oth.name
  end

end
