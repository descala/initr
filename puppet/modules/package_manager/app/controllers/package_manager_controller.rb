class PackageManagerController < InitrController

  menu_item :initr

  before_filter :find_package_manager
  before_filter :authorize

  private

  def find_package_manager
    @klass = Initr::PackageManager.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end
