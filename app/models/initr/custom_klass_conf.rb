class Initr::CustomKlassConf < ActiveRecord::Base

  unloadable

  belongs_to :klass, :class_name => "Initr::CustomKlass"
  validates_presence_of :name, :value

end
