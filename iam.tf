# --------------------------------------------------------------------------------------------------
# Instance Role
# --------------------------------------------------------------------------------------------------
resource "aws_iam_role" "jenkins_role" {
  name               = "${var.stack_name}_role"
  assume_role_policy = file("documents/assumerolepolicy.json")
  path               = "/"
  description        = "${var.stack_name} instance access to s3, ec2, cw, ssm."
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name  = "${var.stack_name}_instance_profile"
  role  = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "jenkins_ec2_ssm_policy" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "jenkins_inline_policy" {
  name = "${var.stack_name}_inline_policy"
  role = aws_iam_role.jenkins_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::dev-mipulse-devops"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::dev-mipulse-devops/rackspace/installers/armor/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "ssm:CreateAssociation"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "logs:CreateLogStream",
                "ec2:DescribeTags",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "ssm:GetParameter"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:DescribeTags"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}


# --------------------------------------------------------------------------------------------------
# EFS Backup
# --------------------------------------------------------------------------------------------------

resource "aws_iam_role" "efs_backup_role" {
  name               = "${var.stack_name}_efs_backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "efs_backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.efs_backup_role.name
}

resource "aws_backup_selection" "efs_backup_selection" {
  iam_role_arn = aws_iam_role.efs_backup_role.arn
  name         = "${var.stack_name}_efs_backup_selection"
  plan_id      = aws_backup_plan.efs.id

  resources = [
    aws_efs_file_system.jenkins.arn,
  ]
}