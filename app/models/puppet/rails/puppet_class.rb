class Puppet::Rails::PuppetClass < ActiveRecord::Base

  establish_connection "puppet_#{RAILS_ENV}"

  has_many :resources
    has_many :source_files
    has_many :hosts
end

# $Id$
