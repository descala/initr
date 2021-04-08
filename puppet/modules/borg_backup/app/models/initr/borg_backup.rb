class Initr::BorgBackup < Initr::Klass

  validates_presence_of :borg_passphrase, :repository, :excludes, :paths,
    :on => :update

  # simple getters and setters for serialized attributes
  self.accessors_for(
    %w(borg_passphrase repository excludes paths keep_daily keep_weekly
    keep_monthly keep_yearly hour minute)
  )

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
    self.keep_daily   ||= "7"
    self.keep_weekly  ||= "4"
    self.keep_monthly ||= "6"
    self.keep_yearly  ||= "0"
    self.hour   ||= '3'
    self.minute ||= '0'
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
