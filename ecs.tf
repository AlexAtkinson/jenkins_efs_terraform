# --------------------------------------------------------------------------------------------------
# Jenkins ECS
# --------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs-agent-cluster" {
  name                 = var.stack_name
  capacity_providers   = FARGATE

  tag {
    key                 = "Name"
    value               = var.stack_name
    propagate_at_launch = "true"
  }

  tag {
    key                 = "environment"
    value               = var.environment
    propagate_at_launch = "true"
  }

  tag {
    key                 = "orchestration"
    value               = var.orchestration
    propagate_at_launch = "true"
  }

  tag {
    key                 = "contact"
    value               = var.contact
    propagate_at_launch = "true"
  }

}
