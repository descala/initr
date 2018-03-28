class InitrMailserver2Controller < InitrController

  menu_item :initr
  before_filter :find_mailserver
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      if @klass.update_attributes(params[:initr_mailserver2])
        flash[:notice] = "Configuration successfully updated."
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  def find_mailserver
    @klass = InitrMailserver2.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
