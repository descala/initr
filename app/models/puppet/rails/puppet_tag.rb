require 'puppet/rails/resource_tag'
class Puppet::Rails::PuppetTag < ActiveRecord::Base
  establish_connection "puppet_#{RAILS_ENV}"
    has_many :resource_tags, :dependent => :destroy
    has_many :resources, :through => :resource_tags
end
