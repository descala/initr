require_dependency 'tracker'

# Taken from http://github.com/edavis10/redmine-budget-plugin/tree/master
# Patches Redmine's Trackers dynamically. Translates trackers names
module TrackerPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def name
      l(read_attribute(:name))
    end
  end

end
