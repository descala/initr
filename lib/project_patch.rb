require_dependency 'project'

# Taken from http://github.com/edavis10/redmine-budget-plugin/tree/master
# Patches Redmine's Projects dynamically. Adds a relationship
# Project +has_many+ Nodes
module ProjectPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
 
    base.send(:include, InstanceMethods)
 
    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :nodes, :class_name => "Initr::Node"
    end
 
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end

end
 
# Add module to Project
Project.send(:include, ProjectPatch)
