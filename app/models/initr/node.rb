require 'user'
require 'date'

class Initr::Node < ActiveRecord::Base

  unloadable

  has_many :reports, :dependent => :destroy, :class_name => "Initr::Report"
  has_many :klasses, :dependent => :destroy, :class_name => "Initr::Klass"
  belongs_to :project
  belongs_to :user

  validates_presence_of :name
  after_destroy :revoke_cert

  def visible_by?(usr)
    return ((usr == user && usr.allowed_to?(:view_own_nodes, nil, :global=>true)) || usr.allowed_to?(:view_nodes, project))
  end

  def editable_by?(usr)
    return ((usr == user && usr.allowed_to?(:edit_own_nodes, nil, :global=>true)) || usr.allowed_to?(:edit_nodes, project))
  end

  def removable_by?(usr)
    return ((usr == user && usr.allowed_to?(:delete_own_nodes, nil, :global=>true)) || usr.allowed_to?(:delete_nodes, project))
  end

  def <=>(oth)
    self.name <=> oth.name
  end

  def parameters
    # node parameters
    parameters = {"node_hash"=>self.name}
    # node classes
    classes = { "base" => nil }
    begin
      klasses.sort.each do |klass|
        begin
          # top scope variables
          parameters = Initr::Klass.merge_parameters(parameters,klass.parameters)
          # class variables
          classes[klass.puppetname] = Initr::Klass.merge_parameters(classes[klass.puppetname],klass.class_parameters)
          # extra classes
          klass.more_classes.each do |klass_to_add|
            classes[klass_to_add] = nil unless classes[klass_to_add]
          end
        rescue Initr::Klass::ConfigurationError => e
          # if klass.parameters raises don't add klass to node
          err = "#{e.message} for node #{self.name}"
          logger.error(err) if logger
          # show message in puppet log
          classes["common::configuration_errors"] = [] unless classes["common::configuration_errors"]
          classes["common::configuration_errors"] << err unless classes["common::configuration_errors"].include? err
        end
      end
    rescue ActiveRecord::SubclassNotFound => e
      logger.error(e.message)
      classes["common::configuration_errors"] = [] unless classes["common::configuration_errors"]
      classes["common::configuration_errors"] << e.message unless classes["common::configuration_errors"].include? e.message
    end
    result = { }
    result["parameters"] = parameters
    result["parameters"]["classes"] = classes.keys.sort
    result["classes"] = classes
    result
  end

  private

  # Creates an empty file on tmp/revoke_requests. In order to revoke deleted nodes
  # puppet certificates, must configure inotify to monitor that directory and call
  # puppet/revoke_cert.sh script
  def revoke_cert
    begin
      revoke_requests_dir="#{RAILS_ROOT}/tmp/revoke_requests"
      FileUtils.mkdir(revoke_requests_dir) unless File.directory? revoke_requests_dir
      FileUtils.touch "#{revoke_requests_dir}/revoke_#{name}"
    rescue Exception => e
      logger.error("Can't create revoke certificate request (#{e.message})")
    end
  end

end
