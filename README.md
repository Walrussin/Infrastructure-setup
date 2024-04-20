# Infrastructure-setup
Setup the infrastructure for a simple web server. Create Resources, Harden, Deploy

### Provision

`terraform plan`

`terraform apply --auto-approve`

### Harden

`ansible-playbook -v -b -i /dev/null --check site.yml`