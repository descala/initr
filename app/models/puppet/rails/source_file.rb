class Puppet::Rails::SourceFile < ActiveRecord::Base
  establish_connection "puppet_#{RAILS_ENV}"
    has_one :host
    has_one :puppet_class
    has_one :resource
end
