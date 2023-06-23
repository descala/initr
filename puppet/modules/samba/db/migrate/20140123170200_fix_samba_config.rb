class FixSambaConfig < ActiveRecord::Migration

  # Fix this YAML. It is invalid. It should bé "%U.cmd"
  #
  # --- 
  #  netlogon_script: %U.cmd
  #
  def self.up
    Initr::Samba.all.each do |s|
      if s.config.is_a?(String)
        new_config = s.config.gsub('%U.cmd','"%U.cmd"')
        s.config = YAML.load(new_config)
        s.save!
      end
    end
  end

  def self.down
    # will not undo this ...
  end

end
