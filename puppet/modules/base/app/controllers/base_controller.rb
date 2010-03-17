class BaseController < InitrController
  unloadable
  helper 'initr'

  layout 'nested'
  menu_item :initr

  before_filter :find_base
  before_filter :authorize

  def configure
    if request.post?
      if @klass.update_attributes(params[:base])
        flash[:notice] = "Configuration successfully updated."
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  private

  def find_base
    @klass = Initr::Base.find(params[:id])
    @node = @klass.node
    @project = @node.project
  end

end
