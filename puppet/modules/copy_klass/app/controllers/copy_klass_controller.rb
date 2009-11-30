class CopyKlassController < ApplicationController
  unloadable

  before_filter :find_copy_klass

  def configure
    @copiable_klasses = []
    User.current.projects.collect {|p| p.nodes }.compact.flatten.sort.each do |node|
      next if node == @node
      n = [node.fqdn, node.klasses.collect {|k| [k.name, k.id.to_s]}]
      @copiable_klasses << n
    end
    if request.post?
      params["copy_klass"] ||= {}
      if @copy_klass.update_attributes(params["copy_klass"])
        flash[:notice]='Configuration saved'
        redirect_to :controller => 'klass', :action=>'list', :id => @node
      else
        render :action=>'configure'
      end
    end
  end

  def find_copy_klass
    @copy_klass = Initr::CopyKlass.find params[:id]
    @node = @copy_klass.node
    @project = @node.project
  end

end
