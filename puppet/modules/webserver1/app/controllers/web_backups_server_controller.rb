class WebBackupsServerController < ApplicationController
  unloadable

  layout 'nested'
  menu_item :initr
  
  before_filter :find_web_backups_server
  before_filter :authorize

  def configure
    if request.post?
      if @wbs.update_attributes params[:web_backups_server]
          flash[:notice] = 'Configuration saved'
          redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end

  private

  def find_web_backups_server
    @wbs = Initr::WebBackupsServer.find params[:id]
    @node = @wbs.node
    @project = @node.project
  end

end
