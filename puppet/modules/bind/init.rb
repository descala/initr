# Redmine initr plugin
require 'redmine'

Rails.logger.info 'Starting bind plugin for Initr'

Initr::Plugin.register :bind do
  name 'bind'
  author 'Ingent'
  description 'DNS server plugin for initr'
  version '0.0.1'
  project_module :initr do
    add_permission :edit_klasses, { :bind => [:configure, :add_zone, :edit_zone, :destroy_zone] }
    # Self-service DNS: lets a logged-in user edit only the zones assigned to
    # them (Initr::BindZoneManager). Necessary-but-not-sufficient — the real
    # gate is per-zone ownership (Initr::BindZone#editable_by? / MyZonesController).
    permission :edit_own_bind_zones,
      { :my_zones => [:index, :edit, :update] },
      :require => :loggedin
  end
  klasses 'bind' => 'DNS server'

  # "My DNS" entry (rendered via application_menu when the user has no project),
  # shown only to users holding the self-service permission.
  menu :application_menu, :my_dns,
    { :controller => 'my_zones', :action => 'index' },
    :caption => :label_my_dns,
    :if => Proc.new { User.current.logged? &&
                      User.current.allowed_to?(:edit_own_bind_zones, nil, :global => true) }

  # Central DNS assignment page in the Administration sidebar. Admin-only — the
  # controller enforces require_admin and the admin_menu only renders for admins.
  menu :admin_menu, :dns_assignments,
    { :controller => 'dns_assignments', :action => 'index' },
    :caption => :label_dns_assignments,
    :html => { :class => 'icon icon-server-authentication' }
end

::I18n.load_path += Dir.glob(File.join("#{File.dirname(__FILE__)}", 'config', 'locales', '*.yml'))
