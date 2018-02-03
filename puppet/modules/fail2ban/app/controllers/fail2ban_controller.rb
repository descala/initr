class Fail2banController < InitrController

  menu_item :initr
  # authorize filter expects @project to be the current project
  # we set this on find_fail2ban filter
  before_filter :find_fail2ban, :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.put?
      params["fail2ban"] ||= {}
      params["fail2ban"]["jails"] ||= {}
      if @klass.update_attributes(params["fail2ban"])
        flash[:notice]='Configuration saved'
      end
    end
  end

  private

  def find_fail2ban
    @klass = Initr::Fail2ban.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
