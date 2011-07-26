
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

  cd redmine/vendor/plugins ; git clone git://github.com/descala/initr.git

* Apply redmine patches on initr/redmine_patches/

::

  cd ../../ ; git apply vendor/plugins/initr/redmine_patches/*.patch

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

* Configure Initr on 'Admin -> Plugins -> Initr' screen

* Add Initr to a project ('Project -> Settings -> Modules') and Initr tab will appear on that project.

* You can start a local puppetmaster by running puppet/start_puppetmaster.sh from initr plugin directory

Considerations
--------------

* Initr is a `Redmine`_ plugin, therefore you need a Redmine installation where install the plugin.

* It is recomended to run a Puppetmaster configured with `storeconfigs`_.

* You'll need to configure puppetmaster `external nodes`_ to call the script provided in bin/external_node.sh which gets node classes and parameters from an initr url.

* Initr accepts http reports on /reports url, so to make reports appear on initr, configure puppetmaster to use http reports

::

  [master]
    reports = http
    reporturl = http://<your_url>/reports

* On development all certificate requests are signed (see puppet/autosign.conf), but it is not desirable on production. See http://www.ingent.net/projects/initr/wiki/SigningRevoking_certificates_automatically to automatically sign certificate requests

.. _storeconfigs: http://projects.puppetlabs.com/projects/puppet/wiki/Using_Stored_Configuration
.. _external nodes: http://docs.puppetlabs.com/guides/external_nodes.html
.. _Redmine: http://www.redmine.org
.. _Puppet: http://docs.puppetlabs.com/guides/introduction.html
.. _project homepage: http://www.ingent.net/projects/initr/wiki
