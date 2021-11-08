require 'facter'

# services list as a fact _

Facter.add('services_list') do
  setcode do
    File.read('/etc/in/services_list.json')
  end
end
