# Infrastructure-setup
Setup the infrastructure for a simple web server. Create Resources, Harden, Deploy

### Provision

`aws configure`

Apply you API key and password.

`terraform init`

`terraform plan`

`terraform apply --auto-approve`

### Harden

`ansible-playbook infra-autoconfig-playbook.yml`

### Deploy

`ansible-playbook deploy-autoconfig-playbook.yml -e "aws_access_key_id=<YOUR ACCESS KEY ID> aws_secret_access_key=<YOUR SECRET ACCESS KEY>"`