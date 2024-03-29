class KlassController < InitrController

  menu_item :initr
  before_action :find_node, :only => [:list,:create,:apply_template,:activate]
  before_action :find_klass, :only => [:configure,:destroy,:move,:copy]
  before_action :authorize
 
  def list
    @facts = @node.facts
    @node.update_fact_cache

    @html_title=[@node.fqdn, "klasses"]
    (render_403; return) unless @node.visible_by?(User.current)
    @klass_definitions = []
    @repeatable_klasses = []
    Initr::KlassDefinition.all.each do |kd|
      if kd.unique?
        @klass_definitions << kd
      else
        @repeatable_klasses << kd
      end
    end
    @klass_definitions.sort!
    @templates = []
    @templates = @node.project.node_templates if User.current.allowed_to?(:view_nodes,@node.project)
    @templates += User.current.node_templates.collect {|t| t if t.visible_by?(User.current)}.compact
    @templates.uniq!

    # TODO this is too slow
    @external_nodes_yaml = YAML.dump @node.parameters if params[:external_nodes]

    flash.now[:error] = @node.config_errors.join("<br />") if @node.config_errors?
    if @node.exported_resources
      @exported_resources = @node.exported_resources 
    else
      @exported_resources = []
    end
  end

  def activate
    if request.post?
      (render_403; return) unless @node.editable_by?(User.current)
      active_klasses = params[:klasses].keys if params[:klasses]
      active_klasses ||= []
      @node.klasses.each do |k|
        if active_klasses.include?(k.type) or active_klasses.include?(k.type.gsub(/^Initr/,''))
          k.active = true
        else
          k.active = false
        end
        k.save(:validate => false)
      end
      new_klasses = params[:new_klasses].keys if params[:new_klasses]
      new_klasses ||= []
      new_klasses.each do |klass_name|
        begin
          # try old naming of plugin models,
          # until we migrate all them to initr namespace
          klass = Kernel.const_get("Initr#{klass_name}").new
        rescue NameError
          klass = Kernel.eval("Initr::#{klass_name}").new
        end
        klass.node = @node
        klass.active = true
        klass.save(:validate => false)
      end
      flash[:info] = "Configuration saved"
    end
    redirect_to :action=>'list', :id=>@node, :tab=>'klasses'
  end

  def create
    begin
      # try old naming of plugin models,
      # until we migrate all them to initr namespace
      klass = Kernel.const_get("Initr#{params[:klass_name].camelize}").new
    rescue NameError
      klass = Kernel.eval("Initr::"+params[:klass_name].camelize).new
    end
    klass.node = @node

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
    if request.post? or request.put?
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
    if request.patch?
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

  def copy
    unless @klass.copyable?
      flash[:error] = "This klass can't be copied"
      redirect_to :action => 'list', :id => @node.id
      return
    end
    @nodes = User.current.projects.collect {|p| p.nodes }.compact.flatten.sort
    if request.post? or request.put?
      unless @nodes.collect {|n| n.id.to_s }.include? params[:klass][:node_id]
        flash[:error] = "Invalid node to copy to"
        render :action => 'copy'
        return
      end
      @new_klass = @klass.clone
      @new_klass.node_id = params[:klass][:node_id]
      if @new_klass.save
        flash[:notice] = "Klass copied"
        redirect_to :action => 'list', :id => @node
      else
        render :action => 'copy'
      end
    end
  end

  def destroy
    @klass = Initr::Klass.find params[:id]
    if @klass.destroy
      flash[:notice] = "Klass deleted"
      redirect_to :action => 'list', :id => @node
    else
      redirect_to :controller => @klass.controller, :action => 'configure', :id => @klass.id
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

  # TODO klass_params
  # attr_accessible :node_id, :type, :config, :name, :description, :klass_id, :active

end
