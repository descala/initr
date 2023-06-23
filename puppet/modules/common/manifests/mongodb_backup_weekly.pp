class common::mongodb_backup_weekly inherits common::mongodb_backup {

  Cron['backup mongodb'] { weekday => '1', hour => '1' }

}
