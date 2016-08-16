require 'facter'

# A.B.C[.D] kernel version

Facter.add("kernel_version") do
  setcode do
    kernelrelease=Facter["kernelrelease"].value
    kernelrelease.split('-').first
  end

end

Facter.add("kernel_version_n") do
  setcode do
    kernel_version=Facter["kernel_version"].value
    abc=kernel_version.split('.')
    sprintf("%d%03d%03d",abc[0],abc[1],abc[2])
  end


end
