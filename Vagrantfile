# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false

  config.vm.define "standalone", primary: true, autostart: true do |box|
    box.vm.box = "centos/7"
    box.vm.box_version = "1901.01"
    box.vm.hostname = 'standalone.local'
    box.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    box.hostmanager.manage_guest = true
    box.hostmanager.aliases = %w(standalone)
    box.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
    box.vm.provider 'virtualbox' do |vb|
      vb.linked_clone = true
      vb.gui = false
      vb.memory = 1024
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/install_agent.sh"
    end
    box.vm.provision "shell", path: "vagrant/vagrant-common.sh"
  end

  config.vm.define "standalone-ubuntu-1804", primary: false, autostart: false do |box|
    box.vm.box = "ubuntu/bionic64"
    box.vm.box_version = "20190903.0.0"
    box.vm.hostname = 'standalone-ubuntu-1804.local'
    box.vm.synced_folder ".", "/vagrant"
    box.hostmanager.manage_guest = true
    box.hostmanager.aliases = %w(standalone-ubuntu-1804)
    box.vm.network "forwarded_port", guest: 8080, host: 8081, auto_correct: true
    box.vm.provider 'virtualbox' do |vb|
      vb.linked_clone = true
      vb.gui = false
      vb.memory = 1024
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/install_agent.sh"
    end
    box.vm.provision "shell", path: "vagrant/vagrant-common.sh"
  end

  config.vm.define "db" do |box|
    box.vm.box = "centos/7"
    box.vm.box_version = "1901.01"
    box.vm.hostname = 'db.local'
    box.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    box.hostmanager.manage_guest = true
    box.hostmanager.aliases = %w(db)
    box.vm.network "private_network", ip: "192.168.168.254"
    box.vm.provider 'virtualbox' do |vb|
      vb.linked_clone = true
      vb.gui = false
      vb.memory = 1024
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/install_agent.sh"
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/run_puppet.sh"
      s.args = ["-b", "/vagrant", "-m", "prepare.pp db.pp" ]
    end
  end

  config.vm.define "dc" do |box|
    box.vm.box = "centos/7"
    box.vm.box_version = "1901.01"
    box.vm.hostname = 'dc.local'
    box.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    box.hostmanager.manage_guest = true
    box.hostmanager.aliases = %w(dc)
    box.vm.network "private_network", ip: "192.168.168.253"
    box.vm.provider 'virtualbox' do |vb|
      vb.linked_clone = true
      vb.gui = false
      vb.memory = 1024
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/install_agent.sh"
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/run_puppet.sh"
      s.args = ["-b", "/vagrant", "-m", "prepare.pp dc.pp" ]
    end
  end
  
  config.vm.define "hc" do |box|
    box.vm.box = "centos/7"
    box.vm.box_version = "1901.01"
    box.vm.hostname = 'hc.local'
    box.vm.synced_folder "./vagrant", "/vagrant"
    box.hostmanager.manage_guest = true
    box.hostmanager.aliases = %w(hc)
    box.vm.network "private_network", ip: "192.168.168.252"
    box.vm.provider 'virtualbox' do |vb|
      vb.linked_clone = true
      vb.gui = false
      vb.memory = 1024
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/install_agent.sh"
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/run_puppet.sh"
      s.args = ["-b", "/vagrant", "-m", "prepare.pp hc.pp" ]
    end
  end
  
  config.vm.define "lb" do |box|
    box.vm.box = "centos/7"
    box.vm.box_version = "1901.01"
    box.vm.hostname = 'lb.local'
    box.vm.synced_folder "./vagrant", "/vagrant"
    box.hostmanager.manage_guest = true
    box.hostmanager.aliases = %w(lb)
    box.vm.network "private_network", ip: "192.168.0.251"
    box.vm.provider 'virtualbox' do |vb|
      vb.linked_clone = true
      vb.gui = false
      vb.memory = 1024
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--hpet", "on"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/install_agent.sh"
    end
    box.vm.provision "shell" do |s|
      s.path = "vagrant/run_puppet.sh"
      s.args = ["-b", "/vagrant", "-m", "prepare.pp lb.pp" ]
    end
  end
end

