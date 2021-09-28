terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27" # Allows only the rightmost version component to increment. For example, to allow new patch
      # releases within a specific minor release, use the full version number: ~> 1.0.4 will allow installation of 
      # 1.0.5 and 1.0.10 but not 1.1.0. This is usually called the pessimistic constraint operator.
    }
  }

  backend "s3" {
    bucket = "jaskaran-learn-terraform-state"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "eu-west-2"
}


module "vpc" {
  source        = "./tf-modules/vpc"
  region_az     = local.region_az
  vpc_cidr      = local.vpc_cidr
  subnet_cidr_1 = local.subnet_cidr_1
  owner         = local.owner
}

module "ecs_cluster_svc_and_task" {
  source     = "./tf-modules/ecs-fargate-svc-and-task"
  stack_name = local.stack_name
  owner      = local.owner
  image      = local.image
  subnet_id  = module.vpc.public_a.id
  sg_id      = module.vpc.allow_web.id
}

