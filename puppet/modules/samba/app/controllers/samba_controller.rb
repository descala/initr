class SambaController < InitrController

  menu_item :initr

  before_filter :find_samba
  before_filter :authorize

  # def configure in InitrController

  private

  def find_samba
    @klass = Initr::Samba.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
