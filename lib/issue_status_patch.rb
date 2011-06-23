require_dependency 'issue_status'

# Taken from http://github.com/edavis10/redmine-budget-plugin/tree/master
# Patches Redmine's IssueStatuses dynamically. Translates issue statuses names.
module IssueStatusPatch
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
 
# Add module to IssueStatus
IssueStatus.send(:include, IssueStatusPatch)
 
 
 
