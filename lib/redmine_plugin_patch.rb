module RedminePluginPatch
  def self.included(base)
    base.class_eval do
      def_field :klasses
      def migration_directory
        File.join(directory, 'db', 'migrate')
      end
    end
  end
end
