# Learn Terraform

The purpose of this repo is to practice implementing terraform basics with AWS 
ECS. This is in preparation for an upcoming stream of work with a new client.

## What this covers

Spinning up a VPC, public subnet, ECS (fargate) service and task. The terraform state file
is stored remotely in an s3 bucket. Deployment is handled by Gitlab CI/CD. So
push your code to github and CI/CD will handle deployment.

## Useful commands

Before running these commands it is _important_ to update the `locals.tf` file to point to your
stack and make sure you have exported the relevant AWS credentials in your terminal.

- terraform fmt -write=true **format your terraform code, use this if it is failing the lint step**
- terraform validate **validate that you have valid terraform**
- terraform plan **preview what infrastructure changes will be applied**
- terraform apply **to apply infrastruture changes**
- terraform destroy **destroy the stack**

## Next steps:

- [  ] switch the ECS containers to be deployed on EC2 and invistigate 
implementing Anisible
