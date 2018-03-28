class Initr::Copier < Initr::Klass

  has_many :copies, :dependent => :destroy, :class_name => "Initr::Copy"

  def parameters
    conf = {}
    copies.each do |copy|
      conf[copy.name] = copy.parameters unless copy.parameters.nil?
    end
    return { "copier_copies" => conf }
  end

  def puppetname
    "copier"
  end

end
