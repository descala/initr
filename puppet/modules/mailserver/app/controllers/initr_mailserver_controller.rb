class InitrMailserverController < InitrController

  menu_item :initr
  before_filter :find_mailserver
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.post? or request.put?
      if @klass.update_attributes(params[:initr_mailserver])
        flash[:notice] = "Configuration successfully updated."
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  def find_mailserver
    @klass = InitrMailserver.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
