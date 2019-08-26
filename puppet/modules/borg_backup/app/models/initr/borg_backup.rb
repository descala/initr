class Initr::BorgBackup < Initr::Klass

  validates_presence_of :borg_passphrase, :repository, :excludes, :paths

  # simple getters and setters for serialized attributes
  self.accessors_for(%w(borg_passphrase repository excludes paths))

  # set some defaults
  after_initialize {
    self.borg_passphrase ||= ""
    self.repository      ||= ""
    self.excludes        ||= <<EOF
/dev
/proc
/sys
/var/run
/run
/lost+found
/mnt
/var/lib/lxcfs
EOF
    self.paths ||= "/"
  }

  # puppet class is named borg_backup
  def name
    "borg_backup"
  end

  # borg_backup don't need top scope vars
  def parameters
    {}
  end

  # here we define class scope variables
  # (parameterized class)
  def class_parameters
    config.merge({
      'excludes' => excludes.lines.collect {|l| l.strip },
      'paths'    => paths.lines.collect    {|l| l.strip }
    })
  end

end
