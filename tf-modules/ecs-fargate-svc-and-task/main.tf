variable owner {}

variable prefix {}

variable image {}


variable subnet_id {}

variable sg_id {}

module "cluster" {
  source = "../ecs-cluster-fargate"
  cluster_suffix = var.prefix
  owner = var.owner
}

# 7. Create an ECS service
resource "aws_ecs_service" "service" {
  name            = "${var.prefix}-svc"
  cluster         = module.cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task-def.arn
  depends_on      = [aws_ecs_task_definition.task-def]
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [var.sg_id]
    assign_public_ip = true
  }

  tags = {
    Owner = var.owner
  }
}

# 8. Create an ECS task definition
resource "aws_ecs_task_definition" "task-def" {
  family                   = var.prefix
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = var.image
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
    Owner = var.owner
  }
}
