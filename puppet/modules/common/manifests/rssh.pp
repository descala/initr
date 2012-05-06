class common::rssh {

   package { "rssh": ensure => installed; }
   file {
     ["/etc/rssh.conf"]:
       source => "puppet:///modules/common/rssh/rssh.conf",
   }

}
