# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.define "keycloak", primary: true, autostart: true do |k|
    k.vm.box = "centos/7"
    k.vbguest.installer_options = { allow_kernel_upgrade: true }
    k.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
    k.vm.network "forwarded_port", guest: 9090, host: 9090, auto_correct: true
    k.vm.provision "shell", inline: <<-SHELL
      rpm -Uvh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
      yum -y install puppet-agent
      source /etc/profile.d/puppet-agent.sh
      setenforce 0
    SHELL
    k.vm.provision "shell", path: "vagrant-common.sh"
  end

  config.vm.define "keycloak-ubuntu-1804", primary: false, autostart: false do |k|
    k.vm.box = "ubuntu/bionic64"
    k.vm.box_version = "20190903.0.0"
    k.vm.network "forwarded_port", guest: 8080, host: 8081, auto_correct: true
    k.vm.provision "shell", inline: <<-SHELL
      wget https://apt.puppetlabs.com/puppet6-release-bionic.deb
      dpkg -i puppet6-release-bionic.deb
      apt-get update
      apt-get install puppet-agent
      echo "export PATH=/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:/usr/share/puppetmaster-installer/bin:$PATH" > /etc/profile.d/puppetlabs.sh
    SHELL
    k.vm.provision "shell", path: "vagrant-common.sh"
  end
end

