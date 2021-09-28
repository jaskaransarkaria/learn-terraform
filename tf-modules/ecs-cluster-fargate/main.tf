# 6. Create an ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name               = "${var.owner}-${var.stack_name}"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  tags = {
    Owner = var.owner
  }
}
