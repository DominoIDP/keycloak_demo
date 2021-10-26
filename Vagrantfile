# -*- mode: ruby -*-
# vi: set ft=ruby :

#the default password for "su root" is simply "vagrant"

## PARAMETERS:

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  
  #https://stackoverflow.com/questions/17845637/how-to-change-vagrant-default-machine-name
  config.vm.define "keycloak-vm"
  config.vm.hostname = "keycloak-vm.mydomain.com"

  config.vm.network "public_network"

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "centos/7"
 
  config.vm.provider "virtualbox" do |vb|
     #vb.gui = true
  
     # Customize the amount of memory on the VM:
     vb.memory = "1024"
  end
  
  config.vm.provision "shell", name: "Upgrade Linux so VirtualBox Guest Additions will install", privileged:true, inline: "yum -y upgrade" 
  
  #reboot after upgrade
  config.vm.provision :shell do |shell|
    shell.privileged = true
    shell.inline = 'echo rebooting'
    shell.reboot = true
  end  
  
  
  config.vbguest.auto_update = false
  config.vm.provision "shell", name: "WORKAROUND for VirtualBox Guest Additions.", privileged: true, inline: <<-SHELL
    VBOX_VERSION_ON_HOST_OS=6.1.22     #This should be set to YOUR host OS release of VirtualBox
	
    rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    rpm -Uvh https://download-ib01.fedoraproject.org/pub/epel/7/aarch64/Packages/d/dkms-2.7.1-1.el7.noarch.rpm
	yum -y install wget perl gcc dkms kernel-devel kernel-headers make bzip2

    wget http://download.virtualbox.org/virtualbox/${VBOX_VERSION_ON_HOST_OS}/VBoxGuestAdditions_${VBOX_VERSION_ON_HOST_OS}.iso
	
    mkdir /media/VBoxGuestAdditions
    mount -o loop,ro VBoxGuestAdditions_${VBOX_VERSION_ON_HOST_OS}.iso /media/VBoxGuestAdditions

    sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
    unset VBOX_VERSION_ON_HOST_OS
  SHELL

  
  # Install some dependencies
  config.vm.provision "shell", privileged: true, inline: <<-SHELL
    yum -y install wget unzip
  SHELL

  # Install/configure java/keycloak
  config.vm.provision "file", source: "keycloak_scripts", destination: "/tmp/keycloak_scripts", run:"always"
  config.vm.provision "shell", name: "fix EOL", privileged:true, inline: "find /tmp/keycloak_scripts -type f | xargs sed -i -e 's/\r$//'"
  config.vm.provision "file", source: "keycloak_config", destination: "/tmp/keycloak_config", run:"always"
  config.vm.provision "shell", name: "fix EOL", privileged:true, inline: "find /tmp/keycloak_config -type f | xargs sed -i -e 's/\r$//'"

  config.vm.provision "shell", name: "install java/keycloak, configure", privileged:true, path: "keycloak_scripts/keycloak_install.sh"

  # change default ssh forward port as not to conflict with domino vm
  config.vm.network :forwarded_port, guest: 22, host: 2223, id: "ssh"

  # Allow access to keycloak through host
  # Note - update keycloak config to match
  config.vm.network "forwarded_port", guest: 8888, host: 8888
end
