# -*- mode: ruby -*-
# # vi: set ft=ruby :
 
VAGRANTFILE_API_VERSION = "2"
 
# We need yaml to read the hosts.yml file
require 'yaml'
 
# Read YAML file with box details
servers = YAML.load_file('hosts.yml')

# Create inventory file for Ansible by reading the hosts.yml file (ugly, but I dont know ruby...)
require "fileutils"
f = File.open("inventory","w")
servers.each do |servers|
 f.puts servers["group"]
 f.puts servers["name"] + "  ansible_ssh_host=" + servers["ip"] + "  ansible_ssh_user=vagrant " + " ansible_ssh_private_key_file=" + servers["private_key"]
end # servers.each
f.close

# Create VM's
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
config.ssh.insert_key = false
 
  if File.directory?("swrepo")
    # our shared folder for installation files
    config.vm.synced_folder "swrepo", "/media/swrepo", :mount_options => ["dmode=777","fmode=777"]
  end
  # Loop through hosts.yml to build VM's
  servers.each do |servers|
    config.vm.define servers["name"] do |srv|
      srv.vm.box = servers["box"]
      srv.vm.hostname = servers["name"]
      srv.vm.network "private_network", ip: servers["ip"]
      srv.vm.provider :virtualbox do |vb|
        vb.name = servers["name"]
        vb.memory = servers["ram"]
        vb.cpus = servers["cpu"]
        os_extra_disk_size = servers["os_extra_disk_size"]
        if servers["os_extra_disk"] == "yes"
          (1..servers["os_num_extra_disk"]).each do |disk_num|
            osdnum = (disk_num + 1)
            portnum = osdnum
            unless File.exist?("#{servers["name"]}-os-disk#{osdnum}.vdi")
              vb.customize ['createhd', '--filename', "#{servers["name"]}-os-disk#{osdnum}.vdi", '--variant', 'standard', '--size', os_extra_disk_size * 1024]
            end
            vb.customize ['storageattach', :id,  '--storagectl', "SATA Controller", '--port', portnum, '--device', 0, '--type', 'hdd', '--medium', "#{servers["name"]}-os-disk#{osdnum}.vdi"]
          end
        end
        db_extra_disk_size = servers["db_extra_disk_size"]
        if servers["db_extra_disk"] == "yes"
          (1..servers["db_num_extra_disk"]).each do |dbdisk_num|
            dbdnum = (dbdisk_num + 1)
            portnum = dbdnum + servers["os_num_extra_disk"] 
            unless File.exist?("#{servers["name"]}-db-disk#{dbdnum}.vdi")
              vb.customize ['createhd', '--filename', "#{servers["name"]}-db-disk#{dbdnum}.vdi", '--variant', 'standard', '--size', db_extra_disk_size * 1024]
            end
            vb.customize ['storageattach', :id,  '--storagectl', "SATA Controller", '--port', portnum, '--device', 0, '--type', 'hdd', '--medium', "#{servers["name"]}-db-disk#{dbdnum}.vdi"]
          end
        end
      end
    end
  end
config.vm.provision :shell, :inline => "service network restart"
# This is the provisioning step performed by Ansible. Uncomment if it should be run as part of vagrant up
# Since the way the provisioning works with multiple machines, its faster to run the provisioning step manually after the machines are built
#
#  config.vm.provision "ansible" do |ansible|
#    ansible.playbook = "lb-nginx.yml"
#    ansible.limit = "all"
#    ansible.groups = {
#        "loadbalancer" => ["lb"],
#         "webservers" => ["web1", "web2","web3"],
#         "all_groups:children" => ["loadbalancer", "webservers"]
#        }
#  end

end
