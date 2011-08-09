
Overview
--------

This module installs fail2ban and configures its jails and email notifications. It can be used standalone or with `Initr`_.

Initr is a Redmine plugin that acts as an external node classifier and provides a GUI to configure puppet modules.

Stuff on app/ and init.rb is only needed by Initr.

Variables
---------

Fail2ban class accepts 3 parameters:

* jails: Array with jails that should be enabled (check values currently accepted at templates/jail.local.erb)

* custom_jails: Text to add directly to configuration

* mailto: email to send notifications to, if any

Example of usage on site.pp
---------------------------

Applying this conf will configure fail2ban with ssh and vsftpd jails, and send notifications to alert@example.com

::
  
  node "fqdn" {
    class { "fail2ban":
      mailto => "alert@example.com",
      jails => ["vsftpd", "ssh"],
    }
  }


Expected external node classifier YAML
--------------------------------------

Fail2ban is a parameterized class, when using an `external node classifier`_ classes must be a hash to pass required variables. This is an example YAML:

::

  classes:
    fail2ban:
      mailto: alert@example.com
      jails:
        - vsftpd
        - ssh


.. _external node classifier: http://docs.puppetlabs.com/guides/external_nodes.html
.. _Initr: http://www.ingent.net/projects/initr/wiki
