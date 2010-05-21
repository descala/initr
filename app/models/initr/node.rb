require 'user'
require 'date'

class Initr::Node < ActiveRecord::Base

  unloadable

  has_many :reports, :dependent => :destroy, :class_name => "Initr::Report"
  has_many :klasses, :dependent => :destroy, :class_name => "Initr::Klass"
  belongs_to :project
  belongs_to :user

  validates_presence_of :name

  def after_create
    b = Initr::Base.new
    self.klasses << b
  end

  def visible_by?(usr)
    return ((usr == user && usr.allowed_to?(:view_own_nodes, project, :global=>true)) || usr.allowed_to?(:view_nodes, project))
  end

  def editable_by?(usr)
    return ((usr == user && usr.allowed_to?(:edit_own_nodes, project, :global=>true)) || usr.allowed_to?(:edit_nodes, project))
  end

  def removable_by?(usr)
    return ((usr == user && usr.allowed_to?(:delete_own_nodes, project, :global=>true)) || usr.allowed_to?(:delete_nodes, project))
  end

  def <=>(oth)
    self.name <=> oth.name
  end

  def parameters
    # node parameters
    parameters = {"node_hash"=>self.name}
    # node classes
    classes = [ "base" ]
    begin
      klasses.sort.each do |klass|
        begin
          klass.parameters.each do |k,v|
            if parameters.keys.include? k
              if parameters[k].class == Array
                parameters[k] << v
                parameters[k].flatten!
              elsif parameters[k].class == Hash
                parameters[k].merge(v)
              else
                parameters[k] = [parameters[k], v]
                parameters[k].flatten!
              end
            else
              parameters[k] = v
            end
          end
          classes << klass.puppetname
          classes += klass.more_classes if klass.more_classes
        rescue Initr::Klass::ConfigurationError => e
          # if klass.parameters raises don't add klass to node
          err = "#{e.message} for node #{self.name}"
          logger.error(err) if logger
          # show message in puppet log
          classes << "configuration_errors"
          parameters["errors"]=[] unless parameters["errors"]
          parameters["errors"] << err unless parameters["errors"].include? err
        end
      end
    rescue ActiveRecord::SubclassNotFound => e
      logger.error(e.message)
      classes << "configuration_errors"
      parameters["errors"]=[] unless parameters["errors"]
      parameters["errors"] << e.message unless parameters["errors"].include? e.message
    end
    result = { }
    result["parameters"] = parameters
    result["parameters"]["classes"] = classes.uniq
    result["classes"] = classes.uniq
    result
  end

end
