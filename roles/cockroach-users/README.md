cockroach-db
=========

Creates one or more databases in the cluster


Requirements
------------

Needs a running cluster

Role Variables
--------------
- databases: A list of databases to create

Dependencies
------------

No role dependencies, but might benefit from having the cockroach-cluster role run first

Example Playbook
----------------

    - hosts: servers
      roles:
         - cockroach-db

License
-------

MIT

Author Information
------------------

Mikael Sandström, @oravirt
