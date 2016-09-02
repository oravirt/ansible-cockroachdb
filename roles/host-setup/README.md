host-setup
=========

- Makes sure ntp is running
- Makes sure the ip-adresses of all nodes in the play are present in /etc/hosts

Requirements
------------

None

Role Variables
--------------
sync_clock: True/False. If true does a ntpdate -u

Dependencies
------------
None

Example Playbook
----------------

    - hosts: servers
      roles:
         - role: host-setup

License
-------

MIT

Author Information
------------------

Mikael Sandström, @oravirt
