class Fail2banController < ApplicationController
  
  unloadable

  # authorize filter expects @project to be the current project
  # we set this on find_fail2ban filter
  before_filter :find_fail2ban
  before_filter :authorize

  # to make right menu appear
  layout "nested"

  # make "initr" item on the top menu the selected one
  menu_item :initr

  def configure
    if request.post?
      params["fail2ban"] ||= {}
      params["fail2ban"]["fail2ban_jails"] ||= {}
      if @fail2ban.update_attributes(params["fail2ban"])
        flash[:notice]='Configuration saved'
        redirect_to :controller=>'klass', :action=>'list', :id=>@node
      else
        render :action=>'configure'
      end
    end
  end

  private

  def find_fail2ban
    @fail2ban = Initr::Fail2ban.find params[:id]
    @node = @fail2ban.node
    @project = @node.project
  end

end