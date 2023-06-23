class MuninServerController < InitrController

  menu_item :initr
  before_action :find_munin_server
  before_action :authorize

  private

  def find_munin_server
    @klass = Initr::MuninServer.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
