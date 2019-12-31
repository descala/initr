class RsyncdController < InitrController

  menu_item :initr

  before_action :find_rsyncd
  before_action :authorize

  # def configure in InitrController

  private

  def find_rsyncd
    @klass = Initr::Rsyncd.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
