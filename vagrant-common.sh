#!/bin/sh
#
# Common part of the Vagrant provisioning
#
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-mysql
puppet module install puppetlabs-java
puppet module install puppetlabs-java_ks
puppet module install puppet-archive
puppet module install camptocamp-systemd
ln -s /vagrant /etc/puppetlabs/code/environments/production/modules/keycloak
puppet apply /vagrant/spec/fixtures/test.pp
