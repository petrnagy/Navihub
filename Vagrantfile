# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise32"

#  config.trigger.after :up do
#    run "vagant ssh 'cd /vagrant;rails server'"
#  end

  config.vm.network :forwarded_port, host: 3000, guest: 3000
  config.vm.network :forwarded_port, host: 5432, guest: 5432

  #config.vm.provision :shell, path: "provision.sh"

  #config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)
  #config.vm.network "private_network", ip: "192.168.56.101"
  config.vm.network :private_network, ip: "10.11.12.13"
  config.vm.synced_folder ".", "/vagrant", :nfs => { :mount_options => ["dmode=777","fmode=777"] }

  config.vm.provider :virtualbox do |vb|
    #vb.gui = true
    config.vm.provision "shell", inline: "cd /vagrant && rails server", run: "always"
  end

end
