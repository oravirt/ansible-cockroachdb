cockroach-cluster
=========

Creates the actual cockroach cluster.
First starts a 'master node', then joins all the other nodes to the master
Uses the 'cockroach_cluster' module.

Requirements
------------

An installation of cockroachdb

Role Variables
--------------
- master_node: The first node to start in the cluster. Defaults to the first node in the group
- stop_cluster: true/false. Set to False. Just there in case you want to stop the cluster

Dependencies
------------

No role dependencies, but might benefit from having the cockroach-install role run first

Example Playbook
----------------

    - hosts: servers
      roles:
         - cockroach-cluster

License
-------

MIT

Author Information
------------------

Mikael Sandström, @oravirt
