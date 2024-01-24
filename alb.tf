# --------------------------------------------------------------------------------------------------
# Jenkins ALB
# --------------------------------------------------------------------------------------------------
resource "aws_lb" "jenkins" {
  name = replace(var.stack_name, "_", "-")

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  internal                         = var.internal
  load_balancer_type               = "application"
  security_groups                  = concat(tolist(var.security_group_alb), tolist([aws_security_group.lb_ec2_sg.id]))
  subnets                          = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    "Environment"   = var.environment
    "Contact"       = var.contact
    "Orchestration" = var.orchestration
  }
}