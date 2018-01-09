Role Name
=========

Does initial config of host

- configures ntp
- configures dnsmasq
- creates dns-entries for all hosts

Requirements
------------
- ntp
- dnsmasq

Role Variables
--------------
None

Dependencies
------------
None

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - init

License
-------

MIT

Author Information
------------------

Mikael Sandström, @oravirt 
