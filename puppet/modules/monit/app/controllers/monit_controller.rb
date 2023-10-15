class MonitController < InitrController

  menu_item :initr
  before_action :find_monit
  before_action :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      params["monit"] ||= {}
      params["monit"]["monit_checks"] ||= []
      if @klass.update(params["monit"])
        flash[:notice]='Configuration saved'
        redirect_to :controller=>'klass', :action=>'list', :id=>@node
      else
        render :action=>'configure'
      end
    end
  end

  private

  def find_monit
    @klass = Initr::Monit.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
