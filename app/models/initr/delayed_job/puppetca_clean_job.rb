#
# Delayed job responsible of:
#
# - Remove node certificate from puppetmaster
#   when it is deleted from initr
#
class Initr::DelayedJob::PuppetcaCleanJob < Struct.new(:hostname)

  def perform
    `#{Setting.plugin_initr_plugin['puppetca']} --clean #{hostname}`
  end

end
