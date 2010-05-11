class InstallController < InitrController
  unloadable

  before_filter :find_node
  menu_item :initr

  def index
  end
  
  def debian
    render :action => 'debian', :layout => false, :content_type => 'text'
  end
  
  def centos
    render :action => 'centos', :layout => false, :content_type => 'text'
  end

  def can_sign
    render :text => true
  end

  private

  def find_node
    @node = Initr::NodeInstance.find_by_name(params[:id])
    unless @node
      render_404
      return
    end
  end
 
end
