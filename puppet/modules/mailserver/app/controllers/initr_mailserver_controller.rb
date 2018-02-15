class InitrMailserverController < InitrController

  menu_item :initr
  before_filter :find_mailserver
  before_filter :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      if @klass.update_attributes(params[:initr_mailserver])
        flash[:notice] = "Configuration successfully updated."
      end
    end
  end

  def find_mailserver
    @klass = InitrMailserver.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
