class KlassController < InitrController
  unloadable

  before_filter :find_node, :only => [:list,:create,:apply_template]
  before_filter :find_klass, :only => [:configure,:destroy,:move]
  before_filter :authorize
 
  layout 'nested' 
  helper :initr
  menu_item :initr
  
  def list
    (render_403; return) unless @node.visible_by?(User.current)
    node_klasses = Initr::KlassDefinition.all_for_node(@node).sort
    @klass_definitions = []
    Initr::KlassDefinition.all.each do |kd|
      unless node_klasses.include?(kd) and kd.unique?
        @klass_definitions << kd
      end
      @klass_definitions.sort!
    end
    @templates = []
    @templates = @node.project.node_templates if User.current.allowed_to?(:view_nodes,@node.project)
    @templates += User.current.node_templates.collect {|t| t if t.visible_by?(User.current)}.compact
    @templates.uniq!
    @facts = @node.puppet_host.get_facts_hash rescue []
    @external_nodes_yaml = YAML.dump @node.parameters
    if @node.puppet_host
      @exported_resources = @node.exported_resources 
    else
      @exported_resources = []
    end
  end
 
  def create
    (render_403; return) unless @node.editable_by?(User.current)
    begin
      # try old naming of plugin models,
      # until we migrate all them to initr namespace
      klass = Kernel.const_get("Initr#{params[:klass_name].camelize}").new({:node_id=>@node.id})
    rescue NameError
      klass = Kernel.eval("Initr::"+params[:klass_name].camelize).new({:node_id=>@node.id})
    end

    # if plugin controller implements "new" method, redirect_to it
    if (eval("#{klass.controller.camelize}Controller")).action_methods.include? "new"
      redirect_to :controller => klass.controller, :action => 'new', :id => @node
    else
      if klass.save
        if klass.controller == 'klass'
          redirect_to :action => 'list', :id => @node.id
        else
          redirect_to :controller => klass.controller, :action => 'configure', :id => klass.id
        end
      else
        flash[:error] = "Error adding class: #{klass.errors.full_messages}"
        redirect_to :back
      end
    end
  end

  def configure
    #TODO
  end

  def apply_template
    if request.post?
      templ = Initr::NodeTemplate.find(params[:templ_id])
      actual_klasses = {}
      @node.klasses.each do |k|
        actual_klasses[k.name] = k
      end
      templ.klasses.each do |k|
        actual_klasses[k.name].destroy if actual_klasses.keys.include? k.name
        @node.klasses << k.class.new(k.attributes)
      end
      @node.save!
    end
    redirect_to :action => 'list', :id => @node
  end

  def move
    unless @klass.movable?
      flash[:error] = "This klass can't be moved"
      redirect_to :action => 'list', :id => @node.id
      return
    end
    @nodes = User.current.projects.collect {|p| p.nodes }.compact.flatten.sort
    if request.post?
      unless @nodes.collect {|n| n.id.to_s }.include? params[:klass][:node_id]
        flash[:error] = "Invalid destination node"
        render :action => 'move'
        return
      end
      @klass.node_id = params[:klass][:node_id]
      if @klass.save
        flash[:notice] = "Klass moved"
        redirect_to :action => 'list', :id => params[:klass][:node_id]
      else
        render :action => 'move'
      end
    end
  end

  def destroy
    @klass = Initr::Klass.find params[:id]
    if @klass.destroy
      flash[:notice] = "Klass deleted"
      redirect_to :action => 'list', :id => @node
    else
      render "#{@klass.controller}/configure"
    end
  end
    
  private
  
  def find_klass
    @klass = Initr::Klass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end
  
  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize
    if params[:action] == "list"
      deny_access unless @node.visible_by?(User.current)
    else
      deny_access unless @node.editable_by?(User.current)
    end
  end

end
