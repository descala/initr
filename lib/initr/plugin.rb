module Initr #:nodoc:

  class PluginNotFound < StandardError; end
  class PluginRequirementError < StandardError; end

  class Plugin < Redmine::Plugin

    def_field :klasses
    # a pointer to parent class variable
    @registered_plugins = Redmine::Plugin.registered_plugins

    def self.directory
      File.join(Rails.root, 'plugins/initr/puppet/modules')
    end

    def directory
      File.join(File.join(Rails.root, 'plugins/initr/puppet/modules'), id.to_s)
    end

    # Returns an array of available klass_names
    def self.klass_names
      klass_names = []
      registered_plugins.values.each do |plugin|
        next unless plugin.klasses
        plugin.klasses.each do |k,v|
          if v.is_a? Hash
            klass_names << Initr::KlassDefinition.new(k,v[:description],v[:unique])
          else
            klass_names << Initr::KlassDefinition.new(k,v)
          end
        end
      end
      klass_names
    end

    def add_permission(name, actions)
      Redmine::AccessControl.permission(name).add_actions(actions) unless Redmine::AccessControl.permission(name).nil?
    end

    def self.load
      puts "**********"
      puts "instead of loading sub-plugins, symlink them to the puppet modules directory:"
      puts "ln -s initr/puppet/modules/* ."
      puts "**********"
    end
  end
end
