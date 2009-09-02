class InitrWpkgController < ApplicationController

  unloadable

  before_filter :find_wpkg

  layout 'nested'
  menu_item :initr

  def configure
    @packages = InitrWpkg.packages_available_from_xml
    if request.post?
      @wpkg.config = params[:config] || {}
      if @wpkg.save
        flash[:notice] = 'Configuration saved'
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      end
    end
  end
  
  private

  def find_wpkg
    @wpkg = InitrWpkg.find params[:id]
    @node = @wpkg.node
    @project = @node.project
  end

  
end
