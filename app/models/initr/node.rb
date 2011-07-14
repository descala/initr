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
    classes = [ "base" ]
    begin
      klasses.sort.each do |klass|
        next unless klass.active?
        begin
          klass.parameters.each do |k,v|
            if parameters.keys.include? k
              parameters[k] = klass.merge_parameter(k,parameters[k])
            else
              parameters[k] = v
            end
          end
          classes << klass.puppetname
          classes += klass.more_classes if klass.more_classes
        rescue Initr::Klass::ConfigurationError => e
          # if klass.parameters raises don't add klass to node
          err = "#{e.message} for node #{self.name}"
          logger.error(err) if logger
          # show message in puppet log
          classes << "configuration_errors"
          parameters["errors"]=[] unless parameters["errors"]
          parameters["errors"] << err unless parameters["errors"].include? err
        end
      end
    rescue ActiveRecord::SubclassNotFound => e
      logger.error(e.message)
      classes << "configuration_errors"
      parameters["errors"]=[] unless parameters["errors"]
      parameters["errors"] << e.message unless parameters["errors"].include? e.message
    end
    result = { }
    result["parameters"] = parameters
    result["parameters"]["classes"] = classes.uniq
    result["classes"] = classes.uniq
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
