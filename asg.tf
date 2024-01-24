# --------------------------------------------------------------------------------------------------
# Jenkins ASG
# --------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "jenkins" {
  depends_on = [aws_efs_file_system.jenkins, aws_launch_configuration.jenkins]

  name                      = var.stack_name
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  launch_configuration      = aws_launch_configuration.jenkins.name
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

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

  tag {
    key                 = "SSMInventory"
    value               = "True"
    propagate_at_launch = "true"
  }
}

