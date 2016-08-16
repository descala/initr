require 'facter'

Facter.add("rubygems_version") do
  setcode do
    begin
      Gem::VERSION
    rescue
      Gem::RubyGemsVersion rescue nil
    end
  end
end
