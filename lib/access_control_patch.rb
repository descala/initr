require 'redmine'

module Redmine

  module AccessControl
    class Permission
      def add_actions(hash)
        hash.each do |controller, actions|
          if actions.is_a? Array
            @actions << actions.collect {|action| "#{controller}/#{action}"}
          else
            @actions << "#{controller}/#{actions}"
          end
        end
      end
    end
  end

  class Plugin
    def add_permission(name, actions)
      AccessControl.permission(name).add_actions(actions) unless AccessControl.permission(name).nil?
    end
  end


end
