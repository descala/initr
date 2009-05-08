require 'puppet/rails/host'

class InitradminController < InitrRequireAdminController
  unloadable

  layout "base"
  
  def index
  end

  def scan_puppet_hosts
    @hosts_exist = Array.new
    @hosts_new = Array.new
    hosts = Puppet::Rails::Host.find :all
    hosts.each do |host|
      if Initr::Node.find_by_name host.name
        @hosts_exist << host.name
      else
        @hosts_new << host.name
        node = Initr::Node.new
        node.name = host.name
        node.save
      end
    end
  end

  def unassigned_nodes
    @projects = Project.find :all
    @nodes = Initr::Node.find :all, :order => "project_id, name"
  end

  def assign_node
    @node=Initr::Node.find params[:id]
    if @node.update_attributes(params[:node])
      flash[:notice] = 'Initr::Node assigned to project.'
    else
      flash[:error] = 'Error in node-project assignation.'
    end
    redirect_to :action => 'unassigned_nodes'
  end

end
