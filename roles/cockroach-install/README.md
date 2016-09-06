cockroach-install
=========

Installs cockroachdb

Requirements
------------

None

Role Variables
--------------
- binary_url:         - the url from where to download the binaries
- binary_version:     - the version
- install_location:   - Path to the installation minus the version. e.g /var/lib/cockroach
- install_version:    - The version. Is appended to the install_location, e.g /var/lib/cockroach/xxxxx/
- cockroach_port:     - the port which to use for the cockroach communication
- http_port:          - the http port for the admin gui

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - cockroach-install

License
-------

MIT

Author Information
------------------

Mikael Sandström, @oravirt
