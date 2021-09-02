#!/bin/sh
#
# Common part of the Vagrant provisioning
#
ln -s /vagrant /etc/puppetlabs/code/environments/production/modules/keycloak
puppet module install puppetlabs-stdlib
puppet module install puppetlabs-mysql
puppet module install puppetlabs-postgresql
puppet module install puppetlabs-java
puppet module install puppetlabs-java_ks
puppet module install puppetlabs-concat
puppet module install puppet-archive
puppet module install camptocamp-systemd
puppet apply /vagrant/spec/fixtures/test.pp
