# shamelessly taken from Foreman project (http://theforeman.org)
#
# copy this file to your report dir - e.g. /usr/lib/ruby/1.8/puppet/reports/
# add this report in your puppetmaster reports - e.g, in your puppet.conf add:
# reports=log, initr # (or any other reports you want)

# URL of your Initr installation
$initr_url="http://localhost:3000"

require 'puppet'
require 'net/http'
require 'uri'

Puppet::Reports.register_report(:initr) do
    Puppet.settings.use(:reporting)
    desc "Sends reports directly to Initr"

    def process
      begin
        uri = URI.parse($initr_url)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https' then
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        req = Net::HTTP::Post.new("/node/store_report?format=yml")
        req.set_form_data({'report' => to_yaml})
        response = http.request(req)
      rescue Exception => e
        raise Puppet::Error, "Could not send report to Initr at #{$initr_url}/node/store_report?format=yml: #{e}"
      end
    end
end
