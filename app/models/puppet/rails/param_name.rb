class Puppet::Rails::ParamName < ActiveRecord::Base
  has_many :param_values
end
