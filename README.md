# terraform-testenv-ansible
A Terraform plan to build an environment for testing Ansible playbooks.

##### Instructions
1. Define a bucket name in `s3-tfstate/terraform.tfvars`
2. Run the terraform plan in `s3-tfstate/`
3. Update the bucket name in the s3 backend block in `ec2/providers.tf`
4. Run the terraform plan in `ec2/`

#####  Plan Overview
1. The `s3-tfstate` plan creates an S3 bucket for storing tfstate
2. The `ec2` plan creates several resources:
   - Three t3.micro EC2 instances running Ubuntu 
   - Three t3.micro EC2 instances running Centos
   - One VPC and associated VPC networking resources
   - One security group allowing SSH inbound and all outbound
   - One EC2 key pair
3. The IP addresses and public/private key of the new instances are printed out to the terminal
   
##### Assumptions
None
