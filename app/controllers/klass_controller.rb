class KlassController < ApplicationController
  unloadable

  before_filter :find_node, :only => [:list,:create]
  before_filter :find_project, :only => [:configure,:destroy]
  before_filter :authorize
  
  layout 'nested' 
  menu_item :initr
  
  def list
    node_klasses = Initr::KlassDefinition.all_for_node(@node).sort
    @klass_definitions = []
    Initr::KlassDefinition.all.each do |kd|
      unless node_klasses.include?(kd) and kd.unique?
        @klass_definitions << kd
      end
      @klass_definitions.sort!
    end
    @facts = @node.puppet_host.get_facts_hash rescue []
    @external_nodes_yaml = YAML.dump @node.parameters
  end
 
  def create
    begin
      # try old naming of plugin models,
      # until we migrate all them to initr namespace
      klass = Kernel.const_get("Initr#{params[:klass_name].camelize}").new
    rescue NameError
      klass = Kernel.eval("Initr::"+params[:klass_name].camelize).new
    end

    # if plugin controller implements "new" method, redirect_to it
    if (eval("#{klass.controller.camelize}Controller")).action_methods.include? "new"
      redirect_to :controller => klass.controller, :action => 'new', :id => @node
    else
      klass.node=@node
      if klass.save
        if klass.configurable?
          redirect_to :controller => klass.controller, :action => 'configure', :id => klass.id
        else
          redirect_to :action => 'list', :id => @node.id
        end
      else
        flash[:error] = "Error adding class: #{klass.errors.full_messages}"
        redirect_to :back
      end
    end
  end

  def destroy
    k = Initr::Klass.find params[:id]
    k.destroy
    redirect_to :back
  end
    
  private
  
  def find_node
    @node = Initr::Node.find params[:id]
    @project = @node.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @klass = Initr::Klass.find params[:id]
    @node = @klass.node
    @project = @node.project
  end
  
end
