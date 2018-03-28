class Initr::Dyndns < Initr::Klass

  validates_presence_of :ddns_domain, :on => :update

  def parameters
    raise Initr::Klass::ConfigurationError.new("Missing domain") unless ddns_domain
    super
  end

  before_create do |me|
    me.ddns_pass = random_password
  end

  def ddns_user
    self.node.fqdn
  end

  self.accessors_for %w( ddns_pass ddns_domain current_ip current_url skip_nagios_check )

  private

  def random_password
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(15) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

end
