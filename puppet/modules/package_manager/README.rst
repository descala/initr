
Overview
--------

This module manages package manager, currently Debian apt. It allows to configure automatic security updates, and specify a set of packages to be installed from the next Debian release repository (with "apt pinning"). It can be used standalone or with `Initr`_.

Initr is a Redmine plugin that acts as an `external node classifier`_ and provides a GUI to configure puppet modules.

Stuff on app/ config/ and init.rb is only needed by Initr.

Variables
---------

Top scope variables:

* packages_from_squeeze: On Debian Lenny, install those packages from Squeeze. Expects an array.

* packages_from_wheezy: On Debian Squeeze, install those packages from Wheezy. Expects an array.

Package manager class accepts security_updates as parameter:

* security_updates: 1 to enable, 0 to disable. If enabled, will install cron-apt and configure it to automatically install security updates.

Example of class usage on site.pp
---------------------------------

::
  
  # node is a Debian Squeeze, but we want puppet from Wheezy
  $packages_from_wheezy = ["puppet"]

  node "ns1.example.com" {

    class { "package_manager":
      security_updates => "1",
    }

  }

node that applies this conf will have automatic security updates enabled. Puppet package will be installed from Wheezy, since /etc/apt/preferences:

::
  # Highest priority to stable
  Package: *
  Pin: release n=squeeze
  Pin-Priority: 700

  Package: *
  Pin: release n=wheezy
  Pin-Priority: 100

  # we want puppet from wheezy
  Package: puppet
  Pin: release n=wheezy
  Pin-Priority: 700


Expected external node classifier YAML
--------------------------------------

package_manager is a parameterized class, when using an `external node classifier`_ classes must be a hash to pass required variables. This is an example YAML:

::

  parameters:
    packages_from_wheezy:
      - puppet
  classes:
    package_manager:
      security_updates: "1"


.. _external node classifier: http://docs.puppetlabs.com/guides/external_nodes.html
.. _Initr: http://www.ingent.net/projects/initr/wiki
