require 'user'
require 'date'

class Initr::Node < ActiveRecord::Base

  unloadable

  has_many :klasses, :dependent => :destroy, :class_name => "Initr::Klass"
  belongs_to :project

  validates_presence_of :name
  
  def after_create
    b = Initr::Base.new
    self.klasses << b
  end
  
  def <=>(oth)
    self.name <=> oth.name
  end

end
