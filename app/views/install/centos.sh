rpm -i http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm
yum -y install puppet

cat << FI > /etc/puppet/puppet.conf
[main]
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = /var/lib/puppet/ssl
[puppetd]
    server = one.ingent.net
    masterport = 443
    factsync = true
    report = true
FI

/etc/init.d/puppet start
