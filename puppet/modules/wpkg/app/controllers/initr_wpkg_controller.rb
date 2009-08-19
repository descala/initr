class InitrWpkgController < ApplicationController

  unloadable

  before_filter :find_initr_wpkg

  layout 'nested'
  menu_item :initr

  def configure
    @packages = InitrWpkg.packages_available_from_xml
    if request.post?
      if @initr_wpkg.update_attributes params[:initr_wpkg]
        flash[:notice] = 'Configuration saved'
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      else
        render :action => 'configure'
      end
    end
  end
  
  private

  def find_initr_wpkg
    @initr_wpkg = InitrWpkg.find params[:id]
    @node = @initr_wpkg.node
    @project = @node.project
  end

  
end
