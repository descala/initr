class common::postfix::centosplus inherits common::postfix::base {
  Package["postfix"] { require => File["/etc/yum.repos.d/CentOS-Base.repo"] }
}
