# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.define "keycloak", primary: true, autostart: true do |ood|
    ood.vm.box = "centos/7"
    ood.vbguest.installer_options = { allow_kernel_upgrade: true }
    ood.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
    ood.vm.provision "shell", inline: <<-SHELL
      rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm
      yum -y install puppet-agent
      source /etc/profile.d/puppet-agent.sh
    SHELL
    ood.vm.provision "shell", path: "vagrant-common.sh"
  end

  config.vm.define "keycloak-ubuntu-1804", primary: false, autostart: false do |ood|
    ood.vm.box = "ubuntu/bionic64"
    ood.vm.box_version = "20190903.0.0"
    ood.vm.network "forwarded_port", guest: 8080, host: 8081, auto_correct: true
    ood.vm.provision "shell", inline: <<-SHELL
      wget https://apt.puppetlabs.com/puppet5-release-bionic.deb
      dpkg -i puppet5-release-bionic.deb
      apt-get update
      apt-get install puppet-agent
      echo "export PATH=/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:/usr/share/puppetmaster-installer/bin:$PATH" > /etc/profile.d/puppetlabs.sh
    SHELL
    ood.vm.provision "shell", path: "vagrant-common.sh"
  end
end

