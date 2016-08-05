class BaseController < InitrController

  menu_item :initr
  before_filter :find_base, :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
    if request.patch?
      if @klass.update_attributes(params[:base])
        flash[:notice] = "Configuration successfully updated."
      end
    end
  end

  private

  def find_base
    @klass = Initr::Base.find(params[:id])
    @node = @klass.node
    @project = @node.project
  end

end
