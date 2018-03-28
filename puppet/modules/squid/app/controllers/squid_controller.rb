class SquidController < InitrController

  menu_item :initr
  before_filter :find_squid
  before_filter :authorize

  private

  def find_squid
    @klass = Initr::Squid.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
