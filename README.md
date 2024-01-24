# Terraform AWS Jenkins Lead module

Creates an auto-scaled, self healing, Jenkins lead server for use in AWS. The Jenkins lead is created via an AutoScaling Group"ASG" and $JENKINS\_HOME is stored on an EFS share. When the ASG creates an ec2 host the latest version of Jenkins is installed, the data directory $JENKINS\_HOME is then mounted. Once a week the ec2 host is recreated via an ASG scheduled action to ensure the latest version of the Jenkins WAR is being used.

## Current State

:warning: This kit has not been maintained since tf 0.12.20. Review for changes in TF, and for absent values.

## AMI Compatibility

The theory is that this recipe will work with any OS so long as the necessary handling is added to the userdata.sh shell script.

## REQUIRED UPDATES TO USE

- backend.tf
- launch-tf.sh

## Use

Launching this stack is facilitated by the launch-tf.sh script, run as follows:

```bash
./launch-tf.sh [ init | plan | apply | destroy ]
```

Notes:

- Currently this script does not support multi-account for multi-env deploys, but can be adjusted easily.

## Resources created

- Jenkins lead ec2 instance, created via an AutoScaling Group "ASG".
- Encrypted EFS share to host $JENKINS_HOME.
- EFS Mount points.
- EFS Backup Plan.
- DNS friendly name in Route53 for connections.
- Application Load balancer "ALB" , forwarding to the Jenkins lead.
- Security groups "SG" for: ec2 & EFS.
- ASG scheduled action to automatically deploy the latest WAR file, default = 00:00 - 00:30 each Sunday morning.
- Custom KMS encryption keys for EFS.
- IAM Role for Instance.

## Key points regarding usage

- Jenkins Server is created automatically via the ASG.
- Jenkins Server rebuilds once a week deploying all the latest security patches and the latest jenkins.war.
- The weekly rebuilds cause a 30 minute outage starting Sunday at 0:00 UTC.
- $JENKINS\_HOME is stored on the EFS share and mounts automatically.
- ALB traffic via HTTP auto re-directs to HTTPS
- The EFS share is encrypted using a custom KMS key.
- EFS is backed as specified by the 'backup_schedule' variable, which is every 6h by default.
- Automatically identifies AMI to use.
- Stores state in S3.
- Multiple stacks can be launched from the same directory thanks to the incorporation of workspace handling into the launch script.
- Multiple stacks with the same name can be deployed by selecting 'yes' when prompted if your stack will be new due to the unique string incorporated into the resource names.
- Crowdstrike agent installed.

### Dependencies and Prerequisites

- A VPC is already in place
- Route 53 zone is already in place
- Terraform version >= 0.12.20
- AWS account

### EFS Backups

$JENKINS\_HOME is stored on an EFS Share. It is advisable to back this up. AWS provide 2 off-the-shelf solutions that will do this automatically:

- [EFS Backup](https://aws.amazon.com/answers/infrastructure-management/efs-backup/) - The solution is deployed via a CloudFormation template.
- AWS Backup - https://aws.amazon.com/backup/ (Probably more straight forward to implement)

### Current supported Operating Systems

- Ubuntu Server 18.04 LTS
- Amazon Linux 2