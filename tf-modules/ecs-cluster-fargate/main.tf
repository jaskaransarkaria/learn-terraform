variable owner {}

variable cluster_suffix {}

# 6. Create an ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name               = "${var.owner}-${var.cluster_suffix}"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  tags = {
    Owner = var.owner
  }
}
