class Puppet::Rails::ResourceTag < ActiveRecord::Base
  establish_connection "puppet_#{RAILS_ENV}"
    belongs_to :puppet_tag
    belongs_to :resource
end
