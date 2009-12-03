class InitrWpkgController < ApplicationController

  unloadable

  before_filter :find_wpkg
  before_filter :authorize

  layout 'nested'
  helper :initr
  menu_item :initr

  def configure
    @packages = InitrWpkg.packages_available_from_xml
    if request.post?
      @klass.config = params[:config] || {}
      if @klass.save
        flash[:notice] = 'Configuration saved'
        redirect_to :controller => 'klass', :action => 'list', :id => @node
      end
    end
  end
  
  private

  def find_wpkg
    @klass = InitrWpkg.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  
end
