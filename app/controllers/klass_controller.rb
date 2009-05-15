class KlassController < ApplicationController
  unloadable

  before_filter :find_node, :only => [:list,:create]
  before_filter :find_project, :only => [:configure,:destroy]
  before_filter :authorize
  
  layout 'nested' 
  
  def list
    @klass_definitions = []
    Initr::KlassDefinition.all.each do |kd|
      unless Initr::KlassDefinition.all_for_node(@node).include? kd or kd.name == "CustomKlass"
        @klass_definitions << kd
      end
    end
    @facts = @node.puppet_host.get_facts_hash rescue []
  end
 
  def create
    if params[:klass_name] == "CustomKlass"
      redirect_to :controller => 'custom_klass', :action => 'new', :id => @node
      return
    end
    begin
      begin
        # try old naming of plugin models,
        # until we migrate all them to initr namespace
        klass = Kernel.const_get("Initr#{params[:klass_name].camelize}").new
      rescue NameError
        klass = Kernel.eval("Initr::"+params[:klass_name].camelize).new
      end
    rescue NameError
      @klass_name = Initr::KlassName.find_by_name params[:klass_name]
      klass = Initr::CustomKlass.new(:klass_name => @klass_name)
      klass.klass_name = @klass_name
    end
    klass.node=@node
    if klass.save
      if klass.configurable?
        redirect_to :controller => klass.controller, :action => 'configure', :id => klass.id
      else
        redirect_to :action => 'list', :id => @node.id
      end
    else
      flash[:error] = "Error adding class: #{klass.error}"
      redirect_to :back
    end
  end

  def destroy
    k = Initr::Klass.find params[:id]
    k.destroy
    redirect_to :back
  end
    
  private
  
  def save_confs(k)
    params[:nodeconfs].split.each do |nc|
      value=params[nc]
      cn = Initr::ConfName.find_by_name nc
      c = Initr::Conf.find(:all, :conditions => ["conf_name_id = ? and klass_id = ?", cn.id, k.id])
      #TODO: raise if c.size > 1 ???
      c = (c.size == 1) ? c[0] : Initr::Conf.new()
      c.klass=k
      c.conf_name=cn
      c.set_value value
      c.save
    end
  end

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
