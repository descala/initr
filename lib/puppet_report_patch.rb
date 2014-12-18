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
