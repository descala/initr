class CustomKlassController < InitrController
  unloadable

  menu_item :initr
  before_filter :find_node,    :only => [:new]
  before_filter :find_node_id, :only => [:create]
  before_filter :find_klass,   :only => [:configure]
  before_filter :authorize

  def configure
    if request.post?
      params[:custom_klass][:existing_custom_klass_conf_attributes] ||= {}
      if @klass.update_attributes(params[:custom_klass])
        redirect_to :controller => 'klass', :action => 'list', :id => @node.id
      else
        render :action => 'configure', :id=>@klass
      end
    end
  end

  def new
    @klass = Initr::CustomKlass.new(:node=>@node)
  end

  def create
    if request.post?
      @klass = Initr::CustomKlass.new(params[:custom_klass])
      @klass.node = @node
      if @klass.save
        redirect_to :controller=>'klass',:action=>'list',:id=>@node
      else
        render :action=>'new', :id=>@node
      end
    end
  end

  private

  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  end

  def find_node_id
    @node = Initr::Node.find params[:node_id]
    @project = @node.project
  end

  def find_klass
    @klass = Initr::CustomKlass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end

end

