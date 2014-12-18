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

    def self.update_klass_names
      klass_names.each do |kn|
        updated = Initr::KlassDefinition.find_by_name(kn.name)
        updated = Initr::KlassDefinition.new(kn.name) if updated.nil?
        updated.description = kn.description
      end
    end

    def add_permission(name, actions)
      Redmine::AccessControl.permission(name).add_actions(actions) unless Redmine::AccessControl.permission(name).nil?
    end

    # override lib_path to rename lib to rails_lib,
    # since lib is used by puppet on pluginsync
    # http://docs.puppetlabs.com/guides/plugins_in_modules.html#module_structure_for_025x
    def self.load
      Dir.glob(File.join(self.directory, '*')).sort.each do |directory|
        if File.directory?(directory)
          lib = File.join(directory, "rails_lib")
          if File.directory?(lib)
            $:.unshift lib
            ActiveSupport::Dependencies.autoload_paths += [lib]
          end
          initializer = File.join(directory, "init.rb")
          if File.file?(initializer)
            require initializer
          end
        end
      end
    end


  end
end
