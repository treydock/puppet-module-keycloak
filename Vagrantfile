# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.define "keycloak", primary: true, autostart: true do |ood|
    ood.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
    ood.vm.provision "shell", inline: <<-SHELL
      rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
      yum -y install puppet-agent
      source /etc/profile.d/puppet-agent.sh
      puppet module install puppetlabs-stdlib
      puppet module install puppetlabs-mysql
      puppet module install puppetlabs-java
      puppet module install puppetlabs-java_ks
      puppet module install puppet-archive
      puppet module install camptocamp-systemd
      ln -s /vagrant /etc/puppetlabs/code/environments/production/modules/keycloak
      puppet apply /vagrant/spec/fixtures/test.pp
    SHELL
  end
end

