class Initr::BindZone < ActiveRecord::Base
  unloadable
  belongs_to :bind, :class_name => "Initr::Bind"
  validates_presence_of :domain, :zone
  validates_uniqueness_of :domain, :scope => 'bind_id'

end
