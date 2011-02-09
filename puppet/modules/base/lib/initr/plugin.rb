module Initr #:nodoc:

  class PluginNotFound < StandardError; end

  class Plugin
    @registered_plugins = {}
    class << self
      attr_reader :registered_plugins
      private :new

      def def_field(*names)
        class_eval do 
          names.each do |name|
            define_method(name) do |*args| 
              args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", *args)
            end
          end
        end
      end
    end
    def_field :klasses
    attr_reader :id
    
    # Plugin constructor
    def self.register(id, &block)
      p = new(id)
      p.instance_eval(&block)
      registered_plugins[id] = p
      update_klass_names
    end
    
    # Register upstream
    def redmine(&block)
      Redmine::Plugin.register id, &block
    end
    
    # Returns an array off all registered plugins
    def self.all
      registered_plugins.values.sort
    end
    
    # Finds a plugin by its id
    # Returns a PluginNotFound exception if the plugin doesn't exist
    def self.find(id)
      registered_plugins[id.to_sym] || raise(PluginNotFound)
    end
    
    # Clears the registered plugins hash
    # It doesn't unload installed plugins
    def self.clear
      @registered_plugins = {}
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
    
    def initialize(id)
      @id = id.to_sym
    end
    
    def <=>(plugin)
      self.id.to_s <=> plugin.id.to_s
    end
    

  end
end
