# --------------------------------------------------------------------------------------------------
# ec2 ssh Security Group
# --------------------------------------------------------------------------------------------------
resource "aws_security_group" "ec2_ssh_sg" {
  name        = "${var.stack_name}.ssh"
  description = "Security group for controlling ssh access to ${var.stack_name} server."
  vpc_id      = var.vpc_id

  # Allow ssh from given CIDR ranges
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = var.trusted_security_groups
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "environment"   = var.environment
    "contact"       = var.contact
    "orchestration" = var.orchestration
  }
}

# --------------------------------------------------------------------------------------------------
# LB to instance SG
# --------------------------------------------------------------------------------------------------
resource "aws_security_group" "lb_ec2_sg" {
  name        = "${var.stack_name}.lb-to-ec2"
  description = "Permit traffic between the lb and the ${var.stack_name} instance."
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Environment"   = var.environment
    "Contact"       = var.contact
    "Orchestration" = var.orchestration
  }
}

# --------------------------------------------------------------------------------------------------
# ec2 access Security Group
# --------------------------------------------------------------------------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "${var.stack_name}.web"
  description = "Security group for controlling web access to the ${var.stack_name} instance."
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = var.security_group_alb
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "TCP"
    security_groups = [aws_security_group.lb_ec2_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Environment"   = var.environment
    "Contact"       = var.contact
    "Orchestration" = var.orchestration
  }
}

# --------------------------------------------------------------------------------------------------
# EFS Security Group
# --------------------------------------------------------------------------------------------------
resource "aws_security_group" "private_subnets" {
  name        = "${var.stack_name}.efs"
  description = "Security group for controlling access to ${var.stack_name} EFS from the private subnets"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidr_blocks
  }

  tags = {
    "environment"   = var.environment
    "contact"       = var.contact
    "orchestration" = var.orchestration
  }
}