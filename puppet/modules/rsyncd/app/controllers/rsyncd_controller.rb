class RsyncdController < InitrController

  menu_item :initr

  before_filter :find_rsyncd
  before_filter :authorize

  # def configure in InitrController

  private

  def find_rsyncd
    @klass = Initr::Rsyncd.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
