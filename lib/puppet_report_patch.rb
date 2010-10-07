module PuppetReportPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def delete_resource_statuses
      @resource_statuses = {}
    end
  end

end

# Add module to Puppet
Puppet::Transaction::Report.send(:include, PuppetReportPatch)
