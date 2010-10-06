#require_dependency 'puppet/transaction/report'

module PuppetReportPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
    end
  end

  module InstanceMethods
    def delete_resource_statuses
      @resource_statuses = {}
    end
  end

end

# Add module to Puppet
Puppet::Transaction::Report.send(:include, PuppetReportPatch)
