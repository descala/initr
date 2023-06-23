class SambaController < InitrController

  menu_item :initr

  before_action :find_samba
  before_action :authorize

  # def configure in InitrController

  private

  def find_samba
    @klass = Initr::Samba.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
