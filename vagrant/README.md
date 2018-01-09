# vagrantfile

## Overview

This project is built with Ansible & Oracle in mind, but it is not limited to just that.
It integrates with https://github.com/oravirt/ansible-oracle, but if all that is needed is to create VM's, the basic Vagrant config works very well for that.

It uses the vagrant `ansible_local` provisioner, meaning that Ansible needs to be installed in the box you're using. If it is not installed Vagrant will try to install it. If that doesn't work you'll have to install it manually.
See http://docs.ansible.com/ansible/intro_installation.html.

If any of these boxes are used: https://app.vagrantup.com/oravirt, Ansible is already installed.

If another box is used and ansible can not be installed for whatever reason, the VM's will still be created, it's just that the DNS part will not be configured.

This project works in the following way:
* `hosts.yml` - contains the configuration for the VM's (cpu,ram,disks,ip) that feeds the `Vagrantfile`
* `Vagrantfile` - builds the VM's as per the configuration in `hosts.yml`
* An Ansible inventory (called `inventory`) is generated, which is later used by the provisioners.
* A base provisioner builds the DNS config using `dnsmasq` and enable ntp
* *The base provisioner will also restart the network stack on the hosts using: `service network restart`. This is a dirty hack to get EL7 VM's to start the private network, which is doesn't always do. EL6 does not have this problem*
* It will optionally run the extra provisioners (Ansible playbooks), if any are defined.
* Each `-` starts a new `hostgroup` with a new set of VM's (see https://github.com/oravirt/vagrantfile#oracle-rac-example-2)


Pre-requisites:

- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)

### Starting the VM's
* `vagrant up` will build the VM's to the specification in `hosts.yml` and run the base provisioner
* If there are extra provisioners defined you need one of the following:
  * `setup=true vagrant up` (if VM's are not created)
  * `setup=true vagrant provision` (if the VM's are already up)


### Submodule
`https://github.com/oravirt/ansible-oracle` is placed in `extra-provision/ansible-oracle` (**`git submodule add https://github.com/oravirt/ansible-oracle extra-provision/ansible-oracle`**)


### hosts.yml variables (with example values)

**`basename_vm: myvm`** - This is the name of VM, it will get a serial number added to the end (myvm1,myvm2 etc)  

**`num_vm: 2`** - This means that 2 VM's will be created. This is also what determines the serial number used for naming VM's, incrementing IP's

**`hostgroup: mygroup`** - This is the group under which the VM's will be placed in the Ansible inventory. Also used when naming shared disks. All VM's within this hostgroup will be grouped in a folder with the same name in Virtualbox

**`domain: mydomain.xxx`** - The domainname for the vm

**`box: oravirt/ol73`** - The vagrant base box you want to use

**`vagrant_user: vagrant`** - Sets the `ansible_ssh_user` parameter in the inventory

**`vagrant_pass: vagrant`** - Sets the `ansible_ssh_pass` parameter in the inventory (if this is used, `vagrant_private_key` should not be set)

**`vagrant_private_key:`** - Sets the `ansible_ssh_private_key_file` parameter in the inventory. (if this is used, `vagrant_pass` should not be set)

**`ram: 4096`** - (MB) The amount of RAM the VM should have

**`cpu: 1`** - The number of cores the VM should have

**`base_pub_ip: 192.168.56.20`** - The base (first) IP that should be used for the VM's (in this example `192.168.56.20/21` will be assigned)

**`base_pub_ip_vip: 192.168.56.130`** - The base (first) IP that should be used for VIP's in the case of RAC (in this example `192.168.56.130/131` will be assigned)

**`scan_addresses: 192.168.56.200,192.168.56.201,192.168.56.202`** - The IP's that should be used for scan-addresses. The ip's that you want to use should be in a comma-separated list. The scan-name will be `hostgroup.domain`

**`base_priv_ip: 172.16.56.20`** - The base (first) IP that should be used for the interconnect in the case of RAC VM's (in this example `172.16.56.20/21` will be assigned)

**`synced_folders:`** These are the folders you want to be made accessible from within the VM. `src` is the path on the host, `dest` is the path in the VM.
```
synced_folders:
   - {src: /Users/miksan/Downloads/oracle, dest: /media/swrepo}
   - {src: /Users/miksan/swingbench, dest: /media/swingbench}
```

**`base_disk_path: /Users/miksan/apps/VBOX`** - If set, all disks (local & shared) created by Vagrant will be placed in the following directory: (`#{base_disk_path}/#{hostgroup}`, i.e '`/Users/miksan/apps/VBOX/mygroup`') . If this is set to the same as the VBOX default (`Default machine folder`), the `hostgroup` directory will be removed after 'vagrant destroy' is performed. If the parameter is set to something else, the directories will not be removed automatically. If the parameter is not set, all disks will be placed in the same directory as `Vagrantfile`.

**`create_local_disk: true`** - `true/false`. Should extra disks be added (non-shared). Created as sparse disks.

**`local_disks:`** These are the non-shared disks you want to create. `size` is in GB, `count` is the number of of disks each `name` should have.  The naming standard is `basename_vm-name-serialnumber`, i.e  (`myvm1-u01-1, myvm1-u01-2, myvm1-u02-1` & `myvm2-u01-1, myvm2-u01-2, myvm2-u02-1` )
```
local_disks:
   - {name: u01, size: 75, count: 2}
   - {name: u02, size: 100, count: 1}
```

**`create_shared_disk: true`** - `true/false`. Should shared disks be added. They will be created when the first VM is created and attached to the rest of the VM's within the `hostgroup`. These disks are not sparse, meaning they will consume the all the space you allocate.

**`shared_disks:`** These are the shared disks you want to create. `size` is in GB, `count` is the number of of disks each `name` should have. The naming standard is `hostgroup-name-serialnumber`, i.e (`mygroup-crs-1, mygroup-crs-2, mygroup-crs-3, mygroup-data-1, mygroup-fra-1, mygroup-fra-2`)
```
shared_disks:
   - {name: crs, size: 4, count: 3}
   - {name: data, size: 8, count: 1}
   - {name: fra, size: 8, count: 2}
```

**`provisioning: path/to/playbook`** - Path to the playbook that will be run after initial provisioning. If this is empty no additional provisioning is performed.

**`provisioning_env_override: false`** - `true/false`. If set to true, it is possible to use environment variables to override the Ansible default variables. This is of course only relevant if an Oracle installation is performed.

### Environment variables that can be used to override defaults
For this to take effect `provisioning_env_override` must be set to `true` in `hosts.yml`.

* **`giver`** - The Grid Infrastructure version. Default is `12.2.0.1`
* **`dbver`** - The Database version. Default is `12.2.0.1`
* **`dbname`**  - The database name. Default is `orcl`
* **`dbtype`**  - The database type (`SI/RAC/RACONENODE`). Default is `SI`
* **`dbstorage`**  - The database storage type (`FS/ASM`). Default is `ASM`
* **`cdb`** - `true/false`. Should the database be a cdb. Default is `false`. If set to true but `numpdbs: 0`, no pdb will be created.
* **`numpdbs`** - The number of pdbs that should be created. Default is `0`.
* **`pdbname`** - The name of the pdb. Default is `orclpdb`. If `numpdbs` > 1, the name will be `pdbname1, pdbname2` etc.
* **`dbmem`** - The amount of sga in MB allocated to the database. Default is `1024` MB
* **`ron_service`** - The service_name allocated for a `RACONENODE` configuration. Default is `dbname_serv`

The following will create a 12.1.0.2 config with a SI cdb and a pdb
* `setup=true giver=12.1.0.2 dbver=12.1.0.2 cdb=true numpdbs=1 vagrant up`

### Generic VM Example (1 hostgroup)
The following example will create 1 VM with no extra disks. No provisioning will be run after the initial base provisioning and no synced folders are mounted in the VM (except for the default `/vagrant`)
``` yaml
- basename_vm: vmtest1
  num_vm: 1
  hostgroup: testgroup
  domain: yyyy.vvv
  box: boxcutter/centos73
  vagrant_user: vagrant
  vagrant_pass:
  vagrant_private_key: /vagrant/base-provision/insecure_private_key
  ram: 1024
  cpu: 1
  base_pub_ip: 192.168.56.20
  create_local_disk: false
  create_shared_disk: false
```

### Oracle SI Example (2 hostgroups)
The following example will create one hostgroup with 1 VM with 2 local disks (u01/u02), and one hostgroup with 2 VM's with 1 local disk (app). No provisioning will be run after the initial base provisioning

``` yaml
- basename_vm: dbnode
  num_vm: 1
  hostgroup: vbox-si-asm
  domain: internal.lab
  box: oravirt/ol69
  vagrant_user: vagrant
  vagrant_pass: vagrant
  vagrant_private_key:
  ram: 4096
  cpu: 1
  base_pub_ip: 192.168.56.20
  base_pub_ip_vip:
  scan_addresses:
  base_priv_ip:
  synced_folders:
     - {src: /Users/miksan/Downloads/oracle, dest: /media/swrepo} #<-- This should point to a directory where the Oracle binaries are placed
  create_local_disk: true
  local_disks:
     - {name: u01, size: 75, count: 1}
     - {name: u02, size: 100, count: 1}
  create_shared_disk: false #<-- False: means the shared disks will not be created
  shared_disks:
     - {name: crs, size: 4, count: 1}
     - {name: data, size: 8, count: 1}
     - {name: fra, size: 8, count: 1}
  provisioning:
  provisioning_env_override: false

- basename_vm: appnode
  num_vm: 2
  hostgroup: appservers
  domain: internal.lab
  box: boxcutter/centos73
  vagrant_user: vagrant
  vagrant_pass:
  vagrant_private_key: /vagrant/base-provision/insecure_private_key
  ram: 4096
  cpu: 1
  base_pub_ip: 192.168.9.40
  synced_folders:
     - {src: /Users/miksan/apps/app1, dest: /media/app1}
  create_local_disk: true
  local_disks:
     - {name: app, size: 50, count: 1}
  create_shared_disk: false
  provisioning:
  provisioning_env_override: false
```
### Oracle RAC Example (1)

This example will create a 2-node cluster, and run the extra provisioning step as defined in `extra-provision/ansible-oracle/vbox-rac-install.yml`

``` yaml
- basename_vm: dbnode
  num_vm: 2
  hostgroup: vbox-rac
  domain: internal.lab
  box: oravirt/ol73
  vagrant_user: vagrant
  vagrant_pass: vagrant
  vagrant_private_key:
  ram: 8192
  cpu: 1
  base_pub_ip: 192.168.100.10
  base_pub_ip_vip: 192.168.100.110
  scan_addresses: 192.168.100.210,192.168.100.211
  base_priv_ip: 172.16.100.10
  synced_folders:
     - {src: /Users/miksan/Downloads/oracle, dest: /media/swrepo}
  create_local_disk: true
  local_disks:
     - {name: u01, size: 75, count: 1}
  create_shared_disk: true
  shared_disks:
     - {name: crs, size: 8, count: 3}
     - {name: data, size: 10, count: 4}
     - {name: fra, size: 20, count: 5}
  provisioning: extra-provision/ansible-oracle/vbox-rac-install.yml
  provisioning_env_override: true
```


### Oracle RAC Example (2)

This example will create two 2-node clusters (to simulate different DC's), and run the extra provisioning steps as defined in `extra-provision/ansible-oracle/vbox-rac-install-dc1.yml` & `extra-provision/ansible-oracle/vbox-rac-install-dc2.yml`

``` yaml
- basename_vm: dbnode-dc1-
  num_vm: 2
  hostgroup: vbox-rac-dc1
  domain: internal.lab
  box: oravirt/ol73
  vagrant_user: vagrant
  vagrant_pass: vagrant
  vagrant_private_key:
  ram: 8192
  cpu: 1
  base_pub_ip: 192.168.100.10
  base_pub_ip_vip: 192.168.100.110
  scan_addresses: 192.168.100.210,192.168.100.211
  base_priv_ip: 172.16.100.10
  synced_folders:
     - {src: /Users/miksan/Downloads/oracle, dest: /media/swrepo}
  create_local_disk: true
  local_disks:
     - {name: u01, size: 75, count: 1}
  create_shared_disk: true
  shared_disks:
     - {name: crs, size: 8, count: 3}
     - {name: data, size: 10, count: 4}
     - {name: fra, size: 20, count: 5}
  provisioning: extra-provision/ansible-oracle/vbox-rac-install-dc1.yml
  provisioning_env_override: false


- basename_vm: dbnode-dc2-
  num_vm: 2
  hostgroup: vbox-rac-dc2
  domain: internal.lab
  box: oravirt/ol73
  vagrant_user: vagrant
  vagrant_pass: vagrant
  vagrant_private_key:
  ram: 8192
  cpu: 1
  base_pub_ip: 192.168.200.10
  base_pub_ip_vip: 192.168.200.110
  scan_addresses: 192.168.200.210,192.168.200.211
  base_priv_ip: 172.16.200.10
  synced_folders:
     - {src: /Users/miksan/Downloads/oracle, dest: /media/swrepo}
  create_local_disk: true
  local_disks:
     - {name: u01, size: 75, count: 1}
  create_shared_disk: true
  shared_disks:
     - {name: crs, size: 8, count: 3}
     - {name: data, size: 10, count: 4}
     - {name: fra, size: 20, count: 5}
  provisioning: extra-provision/ansible-oracle/vbox-rac-install-dc2.yml
  provisioning_env_override: false
```


### How long does it take to install these different configurations.

It (of course) depends on the HW you're running it on. But using a ssd makes a LOT of difference.

A normal 2-node 12.1 RAC installation usually takes ~1H, on a 8GB macbook pro with a ssd. I tested the second RAC example (2 nodes in 2 different DC's) on an Intel NUC with 32GB ram and an nvme ssd and that took slightly less than 2 hours. The provisioning works on 1 hostgroup at the time, meaning it will create VM's and install Oracle on the first hostgroup and then create the VM's and install Oracle on the second hostgroup.

Running the Oracle provisioning part outside of Vagrant in the 'multi-dc' case i.e running on both hostgroups at the same time, cuts the runtime down to ~80min (on the same Intel Nuc hw).

Just creating a VM, and letting the base-provisioner run usually just takes a couple of minutes and is mostly dependent on the size of the box and the IO-capacity of the host.


### Known issues

* If you are using a box where Ansible is not installed and Vagrant can't install Ansible, the base-provisioner will fail. The VM's will still be created though.
