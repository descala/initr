module Rails
  class Plugin
    # override lib_path to rename lib to rails_lib,
    # since lib is used by puppet on pluginsync
    # http://docs.puppetlabs.com/guides/plugins_in_modules.html#module_structure_for_025x
    def lib_path
      File.join(directory, 'rails_lib')
    end
  end
end
