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
    factsync = true
    report = true
    http_proxy_host = proxy.ingent.net
    http_proxy_port = 80
FI

/etc/init.d/puppet start
