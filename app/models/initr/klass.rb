class Initr::Klass < ActiveRecord::Base

  unloadable
  
  belongs_to :node, :class_name => "Initr::Node"

  serialize :config

  # you must override this method and return a name for the class
  # it must be a valid puppet class name, without strange characters or spaces
  def name
    self.class.to_s.gsub(/^Initr::/,'')
  end

  # name to match puppet class in .pp
  def name4puppet
    name
  end

  # you should override this method and return a description for the class
  def description
  end

  def controller
    self.class.to_s.gsub(/^Initr::/,'').underscore
  end
  
  # Variables for puppet
  def parameters
    {}
  end

  # we assume that each class has a controller to configure it
  def configurable?
    true
  end
  
  # information to show about the conf of this class
  def print_parameters
    "-"
  end

  def <=>(oth)
    return -1 if self.name == 'base'
    return  1 if oth.name  == 'base'
    self.name.downcase <=> oth.name.downcase
  end

  # node/list includes this partial on each node that returns a partial name here
  def nodelist_partial
  end

end

