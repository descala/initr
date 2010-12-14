class InstallController < InitrController
  unloadable

  before_filter :find_node
  menu_item :initr
  
  def centos
    render :action => 'centos', :layout => false, :content_type => 'text'
  end

  def debian
    render :action => 'debian', :layout => false, :content_type => 'text'
  end

  def darwin
    render :action => 'darwin', :layout => false, :content_type => 'text'
  end

  # Used by puppet/sign_request.sh to find out if cert should be signed
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
