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


variable tags {
  default = {
    Owner = "jaskaran"
  }
}

# 6. Create an ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name               = "jaskaran-learn-terraform"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  tags = {
    Owner = var.tags.Owner
  }
}

module "vpc" {
  source = "./tf-modules/vpc"
}

# 7. Create an ECS service
resource "aws_ecs_service" "service" {
  name            = "learn-terraform-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  depends_on      = [aws_ecs_task_definition.task-def]
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets         = [module.vpc.public_a.id]
    security_groups = [module.vpc.allow_web.id]
  }

  tags = {
    Owner = var.tags.Owner
  }
}

# 8. Create an ECS task definition
resource "aws_ecs_task_definition" "task-def" {
  family                   = "learn"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "nginx"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  cpu          = "256"
  memory       = "512"
  network_mode = "awsvpc"

  tags = {
    Owner = var.tags.Owner
  }
}

