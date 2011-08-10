
Overview
--------

Module to manage `WPKG`_ server. `WPKG`_ is an automated software deployment, upgrade and removal program for Windows.

This module can be used standalone or with `Initr`_.

Initr is a Redmine plugin that acts as an `external node classifier`_ and provides a GUI to configure puppet modules.

Stuff on app/ and init.rb is only needed by Initr.

Variables
---------

WPKG expects 2 parameters:

* wpkg_base: base directory for WPKG. Should be samba-accessible

* wpkg_profiles: hash with each profile name and an array of applications to associate on each profile.

Functions
---------

WPKG defines a function to download application installers:

::
  
  wpkg::download {
    "firefox5":
      to => "firefox",
      url => "http://download.mozilla.org/?product=firefox-5.0&os=win&lang=ca",
      creates => "Firefox Setup 5.0.exe";
  }

Example of class usage on site.pp
---------------------------------

::
  
  node "smb.example.com" {
    class { "wpkg":
      wpkg_base => "/srv/samba/deploy",
      wpkg_profiles => {
        "default" => [ "winxp_sp3", "firefox5" ]
      },
    }
  }

Expected external node classifier YAML
--------------------------------------

Wpkg is a parameterized class, when using an `external node classifier`_ classes must be a hash to pass required variables. This is an example YAML:

::

  classes:
    wpkg:
      wpkg_base: /srv/samba/deploy
      wpkg_profiles:
        default:
          - winxp_sp3
          - firefox5


.. _external node classifier: http://docs.puppetlabs.com/guides/external_nodes.html
.. _Initr: http://www.ingent.net/projects/initr/wiki
.. _WPKG: http://wpkg.org/
