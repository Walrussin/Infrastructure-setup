# Infrastructure-setup
Setup the infrastructure for a simple web server. Create Resources, Harden, Deploy


### Harden

Ansible provides means of checking compliance without enforcement called --check (aka “dry
run”). To use this mode, run the following:

`ansible-playbook -v -b -i /dev/null --check site.yml`