# --------------------------------------------------------------------------------------------------
# Launch Config
# --------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "jenkins" {
  name_prefix          = "terraform-jenkins-lc-"
  image_id             = data.aws_ami.amazon_linux_2.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.name
  security_groups      = [aws_security_group.ec2_ssh_sg.id, aws_security_group.ec2_sg.id]
  enable_monitoring    = var.enable_monitoring
  user_data            = data.template_file.user_data.rendered

  # Setup root block device
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  # Create before destroy
  lifecycle {
    create_before_destroy = true
  }
}

# --------------------------------------------------------------------------------------------------
# Userdata
# --------------------------------------------------------------------------------------------------
data "template_file" "user_data" {
  template = file("${path.module}/userdata.sh")

  vars = {
    appliedhostname         = var.hostname_prefix
    domain_name             = var.domain_name
    environment             = var.environment
    efs_dnsname             = aws_efs_file_system.jenkins.dns_name
    supplementary_user_data = var.supplementary_user_data
    PACKAGE                 = "falcon-sensor-5.28.0-9205.amzn2.x86_64.rpm"
    TMP_DIR                 = "/tmp"
    CROWD_STRIKE_4_CCID     = ""
    ARMOR_LICENSE_KEY       = var.armor_license_key
  }
}
