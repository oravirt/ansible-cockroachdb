<b> ansible-cockroachdb </b>


**OUTDATED - NEW README COMING SOON**


<b> Requirements:

- Ansible (developed on 2.1.0.0)
- Vagrant (developed on 1.8.1)
- Virtualbox (developed on 5.0.24)
- Internets (needed to download the cockroach and Nginx software)

</b>
After the requirements are fullfilled and the repo is cloned, do the following:

1. hosts.yml defines the number of hosts you want with IP-adresses, cpu, ram etc.
It also sets the path to the vagrant insecure_private_key that is needed for vagrant to communicate with the VM's.
So that should be set to wherever your file is (defaults to c:\Users\<user>\.vagrant.d\ on windows, ~<user>/.vagrant.d/ on Linux/Mac)

2. vagrant up <- this builds the VM's as per the specification in hosts.yml. It also creates the inventory file (inventory) that Ansible will use.

3. ansible-playbook install-cockroachdb.yml -i inventory

optionally add:
- -e sync_clocks=true to force a ntpdate -u before doing the installation
- -e configure_lb=true to configure a Nginx node that will act as loadbalancer for the admin-gui and also for the db cluster.

If you want to add more nodes to the cluster, just modify the hosts.yml file, run vagrant up and run the playbook again.
This will install cockroach on the new node and add it to the cluster.

If the loadbalancer is configured the admin-gui can be reached at http://192.168.9.40:8080, and if not it can be reached on
any of the individual nodes http://192.168.9.4{1..3}:8080


<b> Note </b>
- If this is run on windows you will need to install Ansible in a linux VM (or use docker) and run the playbook from there.
- It is also possible to install Ansible in Babun etc, but it doesn't work so well....
- Ansible is also installed in the Vagrant box that is specified, so it is also possible to run the playbook from one of those VM's.
- Just make the insecure_private_key available to the VM, make sure the permissions are 0600 or 0400 and run the playbook.

e.g
- vagrant ssh lb
- cp /vagrant/insecure_private_key .
- chmod 0400 insecure_private_key
- ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook /vagrant/install-cockroachdb.yml -i /vagrant/inventory
