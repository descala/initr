class mailserver {

  case $operatingsystem {
    "Debian": { include mailserver::debian }
  }

}

