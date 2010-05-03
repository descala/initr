class InstallController < InitrController
  unloadable

  menu_item :initr

  def index
  end
  
  def debian
    render :file => 'install/debian.sh'
  end
  
  def centos
    render :file => 'install/centos.sh'
  end

  
end
