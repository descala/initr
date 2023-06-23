class Initr::SshStationPort < ActiveRecord::Base
  belongs_to :ssh_station

  validates_presence_of :num, :host, :name
  validates_uniqueness_of :num
  validates_uniqueness_of :service,
                          :scope => [:ssh_station_id,  :host],
                          :message => "Service already exists in this node."
  validates_uniqueness_of :name,
                          :scope => [:ssh_station_id],
                          :message => "Name already exists in this node."
  before_validation :assign_port_num

  after_initialize {
    host ||= "localhost"
  }

  def parameters
    [ self.to_s , num ]
  end

  def puppetconf
  end

  def next_port
    self.num = self.num + 1
  end

  def <=>(oth)
    self.num <=> oth.num
  end

  def to_s
    "#{host}:#{service}"
  end

  private

  def assign_port_num
    return if self.num
    last_assigned_port = Initr::SshStationPort.order('num desc').first
    self.num = last_assigned_port.nil? ? 31000 : last_assigned_port.num + 1
  end
end
