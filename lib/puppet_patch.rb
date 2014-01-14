require 'puppet/rails'

module PuppetPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
 
    base.send(:include, InstanceMethods)
 
    # Same as typing in the class
    base.class_eval do
      #unloadable # Send unloadable so it will not be unloaded in development
      begin
        establish_connection("puppet_#{Rails.env}")
      rescue ActiveRecord::AdapterNotSpecified => e
        logger.info "store_configs not configured (#{e.message})"
      end
    end
 
  end
  
  module ClassMethods
    def importHostAndFacts yaml
      facts = YAML::load yaml
      raise "invalid Fact" unless facts.is_a?(Puppet::Node::Facts)

      h=Puppet::Rails::Host.find_or_create_by_name facts.name
      return h.importFacts(facts)
    end
  end
  
  module InstanceMethods
    # import host facts, required when running without storeconfigs.
    # expect a Puppet::Node::Facts
    def importFacts facts
      raise "invalid Fact" unless facts.is_a?(Puppet::Node::Facts)

      time = facts.values[:_timestamp]
      time = time.to_time if time.is_a?(String)
      if last_compile.nil? or (last_compile + 1.minute < time)
        self.last_compile = time
        begin
          # save all other facts
          if self.respond_to?("merge_facts")
            self.merge_facts(facts.values)
            # pre 0.25 it was called setfacts
          else
            self.setfacts(facts.values)
          end
          # we are saving here with no validations, as we want this process to be as fast
          # as possible, assuming we already have all the right settings in Foreman.
          # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
          # TODO: if it was installed by Foreman and there is a mismatch,
          # we should probably send out an alert.
          self.save_with_validation(false)
        rescue
          logger.warn "Failed to save #{name}: #{errors.full_messages.join(", ")}"
          $stderr.puts $!
        end
      end
    end
  end

end
