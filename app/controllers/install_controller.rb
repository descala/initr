class InstallController < InitrController
  unloadable

  layout 'nested'

  def index
  end
  
  def debian
    render :file => 'install/debian.sh'
  end
  
  def centos
    render :file => 'install/centos.sh'
  end

  
end
