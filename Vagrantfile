# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

    config.vm.box = "ubuntu/trusty64"
  
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
    end
  
    config.vm.provision "shell", privileged: false,  inline: <<-SHELL
      
      echo "Updating system & installing essentials..."
      sudo apt-get update
      sudo apt-get install build-essential
      sudo apt-get install libtext-csv-perl

      echo "export LC_CTYPE=en_US.UTF-8" >> /home/vagrant/.bashrc
      echo "export LC_ALL=en_US.UTF-8" >> /home/vagrant/.bashrc

      echo "Reading environment variables..."
      if [ -d /vagrant/env/ ]; then  # Check if env/ directory exists
        for path in /vagrant/env/*; do
          name=${path##*/}
          echo "Adding Env variables from $path"
          while IFS='' read -r var || [[ -n "$var" ]]; do
            echo "$var"
            echo "export $var" >> /home/vagrant/.bashrc
          done < "/vagrant/env/$name"
        done
      fi

      echo "cd /vagrant" >> /home/vagrant/.bashrc
    SHELL
  end
  