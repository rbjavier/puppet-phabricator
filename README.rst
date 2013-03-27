Phabricator pupet module
========================

This module installs `Phabricator <http://phabricator.org/>`_. It is based
on the Ubuntu `installation script
<http://www.phabricator.com/rsrc/install/install_ubuntu.sh>`_
of the Phabricator installation guide.

Details
-------

The module uses the ``apache`` and ``mysql`` modules from
``puppetlabs`` and the ``git`` module at ``rbjavier/puppet-git``.

It configures an ``apache vhost`` and requires enough privileges to
access the ``mysql`` server as expected by the Phabricator
installation. It is meant to perform a complete installation until the
point where you need to add an admin account.

Tested on Ubuntu 12.10.

Usage example
-------------

This will clone the ``phabricator``, ``arcanist`` and ``libphutil``
repositories on ``/home/phab``, and configure an apache vhost for
``phabricator.example.com`` with phabricator's webroot as document
root::

  class { 'phabricator':
    path           => "/home/phab",
    hostname       => 'phabricator.example.com',
    mysql_rootpass => 'secret',
    owner          => 'phab',
    group          => 'phab',
  }