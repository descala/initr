require_dependency 'user'

# Taken from http://github.com/edavis10/redmine-budget-plugin/tree/master
# Patches Redmine's Projects dynamically. Adds a relationship
# User +has_many+ Nodes
module UserInitrPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
 
    base.send(:include, InstanceMethods)
 
    # Same as typing in the class
    base.class_eval do
      has_many :nodes, :class_name => "Initr::Node"
    end
 
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def node_instances
      self.nodes.where("type='Initr::NodeInstance'")
    end
    def node_templates
      self.nodes.where("type='Initr::NodeTemplate'")
    end
  end

end
