# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/focal64"
  config.disksize.size = '40GB'

  config.vm.provision "shell", inline: <<-SHELL

    export DEBIAN_FRONTEND=noninteractive

    apt update
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
    apt-add-repository "deb [arch=amd64] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main"

    apt update
    apt install -y git golang qemu-user-static packer libarchive-tools
    rm -rf packer-builder-arm *>/dev/null

    git clone https://github.com/mkaczanowski/packer-builder-arm
    cd packer-builder-arm
    go mod download
    go build
    cp packer-builder-arm /usr/bin

    cd /home/vagrant
    mkdir -p wisebox

  SHELL

  config.vm.provision "shell",
      path: "packer/scripts/init.sh",
      args: "/home/vagrant/wisebox"

end
