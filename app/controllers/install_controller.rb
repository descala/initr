class InstallController < InitrController
  unloadable

  before_filter :find_node
  before_filter :render_text, :except=>'can_sign'
  menu_item :initr
  layout false
  
  # Used by puppet/sign_request.sh to find out if cert should be signed
  def can_sign
    render :text => true
  end

  def ssl_required?
    return true
  end

  private

  def find_node
    @node = Initr::NodeInstance.find_by_name(params[:id])
    unless @node
      render_404
      return
    end
  end

  def render_text
    render :content_type => 'text'
  end
 
end
