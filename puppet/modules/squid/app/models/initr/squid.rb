class Initr::Squid < Initr::Klass
  validate :valid_cache_size

  after_initialize {
    self.squid_config ||= "http_access allow all"
    self.squid_cache  ||= "2048"
  }

  def name
    "squid"
  end

  def description
    "Squid proxy server"
  end

  def valid_cache_size
    errors.add(:squid_cache, "cache size must be a number") unless squid_cache =~ /^[0-9]+$/
  end

  def squid_cache
    config["squid_cache"]
  end
  def squid_cache=(s)
    config["squid_cache"]=s
  end
  def squid_config
    config["squid_config"]
  end
  def squid_config=(v)
    config["squid_config"]=v
  end
end
