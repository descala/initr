class SshStationServerController < InitrController

  menu_item :initr
  before_action :find_ssh_station_server
  before_action :authorize

  private

  def find_ssh_station_server
    @klass = Initr::SshStationServer.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
