require_dependency 'initr/klass'

# Patches Initr's Klasss dynamically.
module KlassPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def before_destroy
      Initr::LinkKlass.all.each do |ck|
        if ck.copied_klass_id == self.id.to_s
          errors.add_to_base "Cannot delete klass, linked on node #{ck.node.fqdn}"
          return false
        end
      end
    end

    def linked_klasses
      lks = []
      Initr::LinkKlass.all.each do |lk|
        lks << lk if lk.copied_klass_id == self.id.to_s
      end
      lks
    end
  end

end

# Add module to Klass
Initr::Klass.send(:include, KlassPatch)
