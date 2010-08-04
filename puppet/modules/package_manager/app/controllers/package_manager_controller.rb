class PackageManagerController < InitrController
  unloadable

  menu_item :initr

  before_filter :find_package_manager
  before_filter :authorize

  def configure
    if request.post?
      params["package_manager"] ||= {}
      if @klass.update_attributes(params["package_manager"])
        flash[:notice]='Configuration saved'
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action=>'configure'
      end
    end
  end

  private

  def find_package_manager
    @klass = Initr::PackageManager.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
