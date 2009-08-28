cat << FI > /etc/apt/sources.list
# repositoris per defecte debian versio estable
deb http://ftp.fr.debian.org/debian/ lenny main
deb-src http://ftp.fr.debian.org/debian/ lenny main
deb http://security.debian.org/ lenny/updates main
deb-src http://security.debian.org/ lenny/updates main
deb http://volatile.debian.org/debian-volatile lenny/volatile main
deb-src http://volatile.debian.org/debian-volatile lenny/volatile main

#repositoris debian versio testing
deb http://ftp.fr.debian.org/debian squeeze main
FI
cat << FI > /etc/apt/preferences
# + prioritat per stable que testing
Package: *
Pin: release a=stable
Pin-Priority: 700

Package: *
Pin: release a=testing
Pin-Priority: 600

# puppet el volem de testing
Package: puppet
Pin: release a=testing
Pin-Priority: 700
FI
apt-get update
apt-get install -y puppet/testing
apt-get install -y lsb-release

# puppet version >= 0.23
cat << FI > /etc/puppet/puppet.conf
[main]
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = /var/lib/puppet/ssl
[puppetd]
    server = one.ingent.net
    classfile = /var/lib/puppet/state/classes.txt
    localconfig = /var/lib/puppet/localconfig
    factsync = true
    report = true
FI

/etc/init.d/puppet start
