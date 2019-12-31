class Puppet::Rails::Host < ActiveRecord::Base
  has_many :resources, :class_name => "Puppet::Rails::Resource"
  has_many :fact_values, :class_name => "Puppet::Rails::FactValue"

  # returns a hash of fact_names.name => [ fact_values ] for this host.
  def get_facts_hash
    fact_values = self.fact_values.includes(:fact_name).order('fact_names.name')
    return fact_values.inject({}) do | hash, value |
      hash[value.fact_name.name] = value.value
      hash
    end
  end

  def get_exported_resources_hash
    resources_list = self.resources.where(exported: true).order("restype, title")
    return resources_list.inject({}) do | hash, resource |
      hash[resource.name] = resource.param_values.collect {|v| v.value if v.param_name.name == "tag"}.compact.sort.join(" ")
      hash
    end
  end
end
