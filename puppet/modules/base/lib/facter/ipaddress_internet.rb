Facter.add('ipaddress_internet') do
  setcode do
    Facter::Core::Execution.execute('dig -4 +short myip.opendns.com @resolver1.opendns.com')
  end
end
