class FtpServerController < InitrController

  menu_item :initr
  before_action :find_ftp
  before_action :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      if @klass.update_attributes(params[:initr_ftp_server])
        flash[:notice]='Configuration saved'
        redirect_to :action=>'configure'
      else
        render :action=>'configure'
      end
    end
  end

  private

  def find_ftp
    @klass = Initr::FtpServer.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
