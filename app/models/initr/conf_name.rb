class Initr::ConfName < ActiveRecord::Base

  unloadable

  has_many :confs, :class_name => "Initr::Conf"
  has_many :klasses, :through => :confs, :class_name => "Initr::Klass"
  has_and_belongs_to_many :klass_names, :class_name => "Initr::KlassName"

  def validate
    errors.add_to_base("Name must be a valid puppet variable, without strange characters or spaces.") if name =~ /\W/
  end

end
