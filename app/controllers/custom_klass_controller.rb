class CustomKlassController < ApplicationController

  unloadable

  before_filter :find_node,    :only => [:new]
  before_filter :find_node_id, :only => [:create]
  before_filter :find_klass,   :only => [:configure]

  def configure
    if request.post?
      params[:custom_klass][:existing_custom_klass_conf_attributes] ||= {}
      if @custom_klass.update_attributes(params[:custom_klass])
        redirect_to :controller => 'klass', :action => 'list', :id => @node.id
      else
        render :action => 'configure', :id=>@custom_klass
      end
    end
  end

  def new
    @custom_klass = Initr::CustomKlass.new(:node=>@node)
    @custom_klass.custom_klass_confs.build
  end

  def create
    if request.post?
      @custom_klass = Initr::CustomKlass.new(params[:custom_klass])
      @custom_klass.node = @node
      if @custom_klass.save
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
    @custom_klass = Initr::CustomKlass.find params[:id]
    @node = @custom_klass.node
    @project = @node.project
  end

end

