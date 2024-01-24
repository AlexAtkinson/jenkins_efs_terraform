# --------------------------------------------------------------------------------------------------
# EFS FileSystem
# --------------------------------------------------------------------------------------------------
resource "aws_efs_file_system" "jenkins" {
  depends_on = [aws_kms_key.efskey, aws_security_group.private_subnets]

  encrypted        = var.efs_encrypted
  performance_mode = var.performance_mode
  kms_key_id       = aws_kms_key.efskey.arn

  tags = {
    "Name"          = "${var.stack_name}"
    "Environment"   = var.environment
    "Orchestration" = var.orchestration
  }
}

# --------------------------------------------------------------------------------------------------
# Mount points
# --------------------------------------------------------------------------------------------------
resource "aws_efs_mount_target" "private_subnet_a" {
  depends_on      = [aws_efs_file_system.jenkins]
  count           = try(var.private_subnet_ids[0], "") != "" ? 1 : 0
  file_system_id  = aws_efs_file_system.jenkins.id
  security_groups = [aws_security_group.private_subnets.id]
  subnet_id       = var.private_subnet_ids[0]
}

resource "aws_efs_mount_target" "private_subnet_b" {
  depends_on      = [aws_efs_file_system.jenkins]
  count           = try(var.private_subnet_ids[1], "") != "" ? 1 : 0
  file_system_id  = aws_efs_file_system.jenkins.id
  security_groups = [aws_security_group.private_subnets.id]
  subnet_id       = var.private_subnet_ids[1]
}

resource "aws_efs_mount_target" "private_subnet_c" {
  depends_on      = [aws_efs_file_system.jenkins]
  count           = try(var.private_subnet_ids[2], "") != "" ? 1 : 0
  file_system_id  = aws_efs_file_system.jenkins.id
  security_groups = [aws_security_group.private_subnets.id]
  subnet_id       = var.private_subnet_ids[2]
}

# --------------------------------------------------------------------------------------------------
# Backup
# --------------------------------------------------------------------------------------------------
resource "aws_backup_vault" "efs" {
  name        = var.stack_name
  kms_key_arn = aws_kms_key.efskey.arn
}

resource "aws_backup_plan" "efs" {
  depends_on = [aws_backup_vault.efs]
  name       = var.stack_name

  rule {
    rule_name         = "${var.stack_name}_rule"
    target_vault_name = var.stack_name
    schedule          = "cron(${var.backup_schedule})"
    lifecycle {
      delete_after = 14
    }
  }

  tags = {
    "Name"          = "${var.stack_name}"
    "Environment"   = var.environment
    "Orchestration" = var.orchestration
  }

}