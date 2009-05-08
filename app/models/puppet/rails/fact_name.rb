require 'puppet/rails/fact_value'

class Puppet::Rails::FactName < ActiveRecord::Base
  establish_connection "puppet_#{RAILS_ENV}"
  has_many :fact_values, :dependent => :destroy
end

# $Id: fact_name.rb 1952 2006-12-19 05:47:57Z luke $
