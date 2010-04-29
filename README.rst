
Initr plugin
============

Initr automates the lifecycle of computer systems.

From provision to operations, puts and keeps the nodes on track.

It uses `Puppet`_ as enabling technology.

See `project homepage`_ for screenshots and documentation

Quickstart
----------

* You will need puppet lib to be in your RUBYLIB, or just install puppet from your package manager (gem, apt, yum ...)

* Get latest `Redmine`_

::

  git clone git://github.com/edavis10/redmine.git

* Install initr plugin

::

  cd vendor/plugins ; git clone git://github.com/descala/initr.git

* Apply redmine patches on initr/redmine_patches/

::

  git apply vendor/plugins/initr/redmine_patches/*.patch

* Configure config/database.yml

* additionally to redmine tables you can configure the database where puppetmaster stores configs to tell initr where to look for hosts and facts, or you can simply run "rake puppet:import:hosts_and_facts" to load them from YAML

::

  # you can define a puppet_[RAILSENV] database to
  # tell initr where to look for hosts and facts
  puppet_development:
    adapter: mysql
    database: puppet
    username: root
    password:

* Migrate databases

::

  rake db:migrate ; rake db:migrate:plugins

* (Re)Start Redmine and check that it lists initr plugin on 'Admin -> Information' screen.

* You can start a local puppetmaster by running puppet/start_puppetmaster.sh from initr plugin directory

Considerations
--------------

* Initr is a `Redmine`_ plugin, therefore you need a Redmine installation where install the plugin.

* It is recomended to run a Puppetmaster configured with `storeconfigs`_.

* You'll need to configure puppetmaster `external nodes`_ to call the script provided in bin/external_node.sh which gets node classes and parameters from an initr url.

* To make reports appear on initr, you must copy puppet/initr.rb to your puppet reports directory (on Debian /usr/lib/ruby/1.8/puppet/reports/) and configure puppetmaster with "reports = initr"

.. _storeconfigs: http://reductivelabs.com/trac/puppet/wiki/UsingStoredConfiguration
.. _external nodes: http://reductivelabs.com/trac/puppet/wiki/ExternalNodes
.. _Redmine: http://www.redmine.org
.. _Puppet: http://puppet.reductivelabs.com
.. _project homepage: http://www.initr.org
