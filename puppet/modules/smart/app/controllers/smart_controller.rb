class SmartController < InitrController

  menu_item :initr
  before_action :find_smart
  before_action :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      if params["smart"] and params["smart"]["drives"] and params["smart"]["drives"]["drive"]
        params["smart"]["drives"] = [params["smart"]["drives"]["drive"],params["smart"]["drives"]["mode"]]
      end
      params["smart"]["drives"] ||= [[],[]] if params["smart"]
      if @klass.update_attributes params["smart"]
        flash[:notice]='Configuration saved'
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  private

  def find_smart
    @klass = Initr::Smart.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
