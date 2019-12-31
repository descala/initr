class Puppet::Rails::PuppetTag < ActiveRecord::Base
  has_many :resources, :through => :resource_tags
end
