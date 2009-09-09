class Puppet::Rails::SourceFile < ActiveRecord::Base
    establish_connection "puppet_#{RAILS_ENV}"
    has_one :host
    has_one :resource

    def to_label
      "#{self.filename}"
    end
end
