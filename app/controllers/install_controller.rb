class InstallController < ApplicationController
  unloadable

  layout 'nested'
  
  def debian
    render :file => 'install/debian.sh'
  end
  
  def centos
    render :file => 'install/centos.sh'
  end

  
end
