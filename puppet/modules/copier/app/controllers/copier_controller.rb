class CopierController < InitrController

  menu_item :initr

  before_action :find_copier, :except => [:edit_copy,:destroy_copy]
  before_action :find_copy,  :only   => [:edit_copy,:destroy_copy]
  before_action :authorize

  def configure
    @html_title=[@node.fqdn, @klass.name]
  end

  def new_copy
    @copy = Initr::Copy.new(params[:copy])
    @copy.copier = @klass
    if request.post?
      if @copy.save
        flash[:notice] = 'Configuration successfully updated.'
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'new_copy'
      end
    end
  end

  def edit_copy
    if request.post?
      if @copy.update(params[:copy])
        flash[:notice] = 'Configuration successfully updated.'
        redirect_to :action => 'configure', :id => @klass
      else
        render :action => 'edit_copy'
      end
    end
  end

  def destroy_copy
    if request.post?
      @copy.destroy
    end
    redirect_to :action => 'configure', :id => @klass
  end

  private

  def find_copier
    @klass = Initr::Copier.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

  def find_copy
    @copy = Initr::Copy.find params[:id]
    @klass = @copy.copier
    @node = @klass.node
    @project = @node.project
  end

end
