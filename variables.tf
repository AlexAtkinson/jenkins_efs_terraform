# ---------------------------------------------------------------------------------------------------
# Resource Name Components
# ---------------------------------------------------------------------------------------------------
variable "stack_name" {
  description = "A unique stack name. Ex: <env>-<project>-<jenkins>"
  default     = null
  type        = string
}

variable "uniquer" {
  description = "A string with which to make this stack unique. Ex: as4knr"
  default     = null
  type        = string
}

variable "environment" {
  description = "Environment where resources are being created, for example dev, uat or prod"
}

# ---------------------------------------------------------------------------------------------------
# ARMOR
# ---------------------------------------------------------------------------------------------------

variable "armor_license_key" {
  description = "Your Armor license key."
  default     = null
  type        = string
}

# ---------------------------------------------------------------------------------------------------
# AWS
# ---------------------------------------------------------------------------------------------------
variable "aws_region" {
  description = "The region to execute terraform commands against."
  default     = null
}

variable "aws_profile" {
  description = "The awscli profile with which to execute."
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "supplementary_user_data" {
  description = "Supplementary shell script commands to execute at the end of the default user data."
  default     = "#supplementary_user_data"
}

variable "autoscaling_schedule_create" {
  description = "Enable ASG Scaling Schedule? Enter 1 (default) to enable, 0 to disable."
  default     = 1
}

variable "zone_id" {
  description = "Route 53 zone id for the zone in which to create the DNS record for the ALB."
}

variable "domain_name" {
  description = "Domain Name for the ALB. Ex: jenkins.domain.com"
}

variable "success_codes" {
  description = "Success Code for the Target Group Health Checks. Default is 403 (forbidden)."
  default     = "403"
}

variable "trusted_security_groups" {
  description = "List of the trusted secuirty groups that have ssh access to the ec2 host.  Ex: [\"foo\",\"bar\"]"
  type        = list(string)
}

variable "security_group_alb" {
  description = "Pre-existing ALB Security Group(s) to assign to the ALB. Ex: [\"foo\",\"bar\"]"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM issued certificate to use."
}

variable "key_name" {
  description = "ec2 Key Pair to assign the ec2 Instance."
}

variable "instance_type" {
  description = "ec2 instance type. Default: t2.micro."
  default     = "t3a.medium"
}

variable "contact" {
  description = "Contact email address for the resources that will be created. This is a Tag."
}

variable "hostname_prefix" {
  description = "Hostname prefix for the Jenkins server."
  default     = "jenkins"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from AZ1 to AZ[x]. Ex: [\"foo\",\"bar\"]"
  type        = list(string)
}

variable "orchestration" {
  description = "Link to the orchestration used. Ex: www.github.com/some-repo."
}

variable "encrypted" {
  description = "Enables/Disables encryption of volumes. Default: true"
  default     = "true"
}

# ---------------------------------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------------------------------
variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB placement from AZ1 to AZ[x].  Ex: [\"foo\",\"bar\"]"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable/Disable deletion protection for the ALB. Default: false"
  default     = "false"
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable/Disable cross zone load balancing. Default: false"
  default     = "false"
}

variable "internal" {
  description = "Create internal load balancer? Default: false"
  default     = "false"
}

variable "http_listener_required" {
  description = "Create HTTP listener with 301 redirect to HTTPS? Default: true"
  default     = "true"
}

variable "healthy_threshold" {
  description = "TG healthy count. Default: 2"
  default     = "2"
}

variable "unhealthy_threshold" {
  description = "TG unhealthy count. Default: 10"
  default     = "10"
}

variable "timeout" {
  description = "TG health check timeout. Default: 5"
  default     = "5"
}

variable "interval" {
  description = "TG health check interval. Default: 20"
  default     = "20"
}

variable "svc_port" {
  description = "Service port: The port on which targets receive traffic."
  default     = "8080"
}

variable "target_group_path" {
  description = "TG health check request path."
  default     = "/"
}

variable "target_group_protocol" {
  description = "The protocol the TG uses to connect to targets."
  default     = "HTTP"
}

variable "target_group_port" {
  description = "The port the TG uses to connect with targets."
  default     = "8080"
}

# ---------------------------------------------------------------------------------------------------
# EFS
# ---------------------------------------------------------------------------------------------------
variable "efs_encrypted" {
  description = "Encrypt the EFS share. Default: true"
  default     = "true"
}

variable "performance_mode" {
  description = "EFS performance mode. Default: generalPurpose. Ref: https://docs.aws.amazon.com/efs/latest/ug/performance.html"
  default     = "generalPurpose"
}

variable "private_subnet_cidr_blocks" {
  description = "Private subnet CIDR blocks. Ex: [\"foo\",\"bar\"]"
  type        = list(string)
}

variable "backup_schedule" {
  description = "Cron formatted schedule for EFS backup plan. Default: 0 0/6 * * ? *"
  default     = "0 0/6 * * ? *"
}

# ---------------------------------------------------------------------------------------------------
# ASG & LC
# ---------------------------------------------------------------------------------------------------

variable "max_size" {
  description = "ASG max size."
  default     = "1"
}

variable "min_size" {
  description = "ASG min size."
  default     = "1"
}

variable "desired_capacity" {
  description = "ASG desired capacity."
  default     = "1"
}

variable "enable_monitoring" {
  description = "AutoScaling - enables/disables detailed monitoring. Default: false"
  default     = "false"
}

variable "health_check_grace_period" {
  description = "AutoScaling health check grace period. Default: 180"
  default     = "180"
}

variable "health_check_type" {
  description = "AutoScaling health check type. Default: ELB"
  default     = "ELB"
}

variable "volume_type" {
  description = "ec2 volume type. Default: gp2"
  default     = "gp2"
}

variable "volume_size" {
  description = "Root volume size for the instance. Default: 30GB"
  default     = "30"
}

variable "scale_up_cron" {
  description = "Cron formatted schedule for weekly scale-out activity (instance refresh). Default: 30 0 * * SUN"
  default     = "30 0 * * SUN"
}

variable "scale_down_cron" {
  description = "Cron formatted schedule for weekly scale-in activity (instance refresh). Default: 0 0 * * SUN"
  default     = "0 0 * * SUN"
}