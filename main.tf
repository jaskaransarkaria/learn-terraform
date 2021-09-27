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
    bucket = var.s3_bucket
    key    = "terraform.tfstate"
    region = var.region
  }

  required_version = ">= 0.14.9"
}
provider "aws" {
  region = var.region
}

# 1. Create vpc
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Owner = var.tags.Owner
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Owner = var.tags.Owner
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Owner = var.tags.Owner
  }
}

# 4. Create a Subnet 
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_1
  availability_zone       = var.region_az
  map_public_ip_on_launch = true

  tags = {
    Owner = var.tags.Owner
  }
}

# 5. Associate subnet with Route Table
resource "aws_main_route_table_association" "main_rtb_association" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.rtb.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # means any
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = var.tags.Owner
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

# 7. Create an ECS service
resource "aws_ecs_service" "service" {
  name            = "learn-terraform-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  depends_on      = [aws_ecs_task_definition.task-def]
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets         = [aws_subnet.public_a.id]
    security_groups = [aws_security_group.allow_web.id]
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

