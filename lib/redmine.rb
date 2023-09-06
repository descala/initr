require 'redmine'

# access control patch

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
end
