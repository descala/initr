class SquidController < InitrController

  menu_item :initr
  before_action :find_squid
  before_action :authorize

  private

  def find_squid
    @klass = Initr::Squid.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
