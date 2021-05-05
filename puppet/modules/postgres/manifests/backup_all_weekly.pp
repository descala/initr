class postgres::backup_all_weekly inherits postgres::backup_all {

  Cron['backup postgres all db'] { weekday => '1', hour => '1' }

}
