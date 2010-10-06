# shamelessly taken from Foreman project (http://theforeman.org)
class Initr::Report < ActiveRecord::Base
  
  unloadable

  belongs_to :node, :class_name => "Initr::NodeInstance"
  serialize :log, Puppet::Transaction::Report
  validates_presence_of :log, :node_id, :reported_at, :status
  validates_uniqueness_of :reported_at, :scope => :node_id

  #TODO: 2 last metrics (applied failed_restarts) only used by puppet < 2.6
  METRIC = %w[skipped failed failed_to_restart restarted changed applied failed_restarts]
  BIT_NUM = 4
  MAX = (1 << BIT_NUM) -1 # maximum value per metric

  # search for a metric - e.g.:
  # Report.with("failed") --> all reports which have a failed counter > 0
  # Report.with("failed",20) --> all reports which have a failed counter > 20
  named_scope :with, lambda { |*arg| { :conditions =>
    "(status >> #{BIT_NUM*METRIC.index(arg[0])} & #{MAX}) > #{arg[1] || 0}"}
  }

  # returns recent reports
  named_scope :recent, lambda { |*args| {:conditions => ["reported_at > ?", (args.first || 1.day.ago)]} }

  # with_changes
  named_scope :with_changes, {:conditions => "status != 0"}

  # a method that save the report values (e.g. values from METRIC)
  # it is not supported to edit status values after it has been written once.
  def status=(st)
    s = st if st.is_a?(Integer)
    s = Initr::Report.calc_status st if st.is_a?(Hash)
    write_attribute(:status,s) unless s.nil?
  end

  #returns metrics
  #when no metric type is specific returns hash with all values
  #passing a METRIC member will return its value
  def status(type = nil)
    raise "invalid type #{type}" if type and not METRIC.include?(type)
    h = {}
    (type || METRIC).each do |m|
      h[m] = (read_attribute(:status) || 0) >> (BIT_NUM*METRIC.index(m)) & MAX
    end
    return type.nil? ? h : h[type]
  end

  # generate dynamically methods for all metrics
  # e.g. Report.last.changed
  METRIC.each do |method|
    define_method method do
      status method
    end
  end

  # returns true if total error metrics are > 0
  def error?
    %w[failed failed_to_restart failed_restarts].sum {|f| status f} > 0
  end

  # returns true if total action metrics are > 0
  def changes?
    %w[applied changed restarted].sum {|f| status f} > 0
  end

  def to_s
    reported_at.to_s
  end

  def config_retrieval
    t = validate_meteric("time", :config_retrieval)
    t.round_with_precision(2) if t
  end

  def runtime
    t = validate_meteric("time", :total)
    t.round_with_precision(2) if t
  end

  #imports a YAML report into database
  def self.import(yaml)
    report = YAML.load(yaml)
    raise "Invalid report" unless report.is_a?(Puppet::Transaction::Report)
    begin
      node = Initr::NodeInstance.find_by_name report.host
      if node.nil? # old puppet versions send hostname instead of certname
        Initr::NodeInstance.all.collect { |n|
          if n.fqdn == report.host
            node = n
            break
          end
        }
      end
      raise "Can't find node #{report.host}" if node.nil?
      logger.info "processing report for #{node.fqdn}"

      # parse report metrics
      raise "Invalid report: can't find metrics information for #{node.fqdn} at #{report.id}" if report.metrics.nil?
      # convert report status to bit field
      st = calc_status(metrics_to_hash(report))

      # update node record
      # we update our node record, so we wont need to lookup the report information just to display the node list / info
      # save our report time
      node.last_report = report.time if node.last_report.nil? or node.last_report < report.time

      # we save the raw bit status value in our node too.
      node.puppet_status = st

      # we save the node without validation for two reasons:
      # 1. It might be auto imported, therefore might not be valid (e.g. missing partition table etc)
      # 2. We want this to be fast and light on the db.
      # at this point, the report is important, not as much of the node
      node.save_with_validation(false)

      # and save our report
      self.create! :node => node, :reported_at => report.time, :log => report, :status => st

    rescue Exception => e
      if node.nil?
        logger.warn "Failed to process report for #{report.host}"
      else
        logger.warn "Failed to process report for #{node.fqdn} due to:#{e}"
      end
      false
    end
  end

  # returns a hash of nodes and their recent reports metric counts which have values
  # e.g. non zero metrics.
  # first argument is time range, everything afterwards is a node list.
  # TODO: improve SQL query (so its not N+1 queries)
  def self.summarise(time = 1.day.ago, *nodes)
    list = {}
    raise "invalid node list" unless nodes
    nodes.flatten.each do |node|
      # set default of 0 per metric
      metrics = {}
      METRIC.each {|m| metrics[m] = 0 }
      node.reports.recent(time).all(:select => "status").each do |r|
        metrics.each_key do |m|
          metrics[m] += r.status(m)
        end
      end
      list[node.name] = {:metrics => metrics, :id => node.id} if metrics.values.sum > 0
    end
    return list
  end

  # add sort by report time
  def <=>(other)
    self.created_at <=> other.created_at
  end

  # Expire reports based on time and status
  # Defaults to expire reports older than a week regardless of the status
  def self.expire(conditions = {})
    timerange = conditions[:timerange] || 1.week
    status = conditions[:status]
    cond = "reported_at < \'#{(Time.now - timerange).to_formatted_s(:db)}\'"
    cond += " and status = #{status}" unless status.nil?
    # delete the reports
    count = Initr::Report.delete_all(cond)
    logger.info Time.now.to_s + ": Expired #{count} Reports"
    return count
  end

  def self.count_puppet_runs(interval = nil)
    interval ||= SETTINGS[:puppet_interval] / 10
    counter = []
    now=Time.now
    (1..(SETTINGS[:puppet_interval] / interval)).each do
      ago = now - interval.minutes
      counter << [ now.getlocal, Initr::Report.count(:all, :conditions => {:reported_at => ago..(now-1.second)})]
      now = ago
    end
    counter
  end

  protected

  # Converts metrics form Puppet report into a hash
  # this hash is required by the calc_status method
  def self.metrics_to_hash(report)
    resources = report.metrics["resources"]
    report_status = {}

    # find our metric values
    METRIC.each { |m| report_status[m] = (resources[m.to_sym].nil? ? 0 : resources[m.to_sym]) }
    # special fix for false warning about skips
    # sometimes there are skip values, but there are no error messages, we ignore them.
    if report_status["skipped"] > 0 and ((report_status.values.sum) - report_status["skipped"] == report.logs.size)
      report_status["skipped"] = 0
    end
    return report_status
  end

  # converts a hash into a bit field
  # expects a metrics_to_hash kind of hash
  def self.calc_status (hash = {})
    st = 0
    hash.each do |type, value|
      value = MAX if value > MAX # we store up to 2^BIT_NUM -1 values as we want to use only BIT_NUM bits.
      st |= value << (BIT_NUM*METRIC.index(type))
    end
    return st
  end

  def validate_meteric (type, name)
    log.metrics[type][name].to_f
  rescue Exception => e
    logger.warn "failed to process report due to #{e}"
    nil
  end

end
