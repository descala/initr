class common::apt {

  # Only purpose of this class is to allow
  # other classes to trigger apt-get update
  exec {
    "apt-get update":
      refreshonly => true;
  }

}
