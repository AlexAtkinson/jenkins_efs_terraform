#!/bin/bash

set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

awk -F= '/^NAME/{print $2}' /etc/os-release | grep -i ubuntu
RESULTUBUNTU=$?
if [ $RESULTUBUNTU -eq 0 ]; then
  
  # Set hostname, ensure it remains   
  hostnamectl set-hostname ${appliedhostname}.${domain_name}
  #  Create initial hostname entry to remove:
  #  'unable to resolve host ubuntu' error
  echo $(hostname -I | cut -d\  -f1) $(hostname) | sudo tee -a /etc/hosts
  # Install Java 1.8.0_181
  /usr/bin/apt-get update -y
  /usr/bin/apt install openjdk-8-jre-headless -y
  # Create EFS mount folder & mount
  # Wait to ensure DNS propagation of the EFS endpoint
  sleep 15
  /usr/bin/apt-get install nfs-common amazon-efs-utils -y
  mkdir /efsmnt
  #mount -t efs -o tls ${efs_dnsname}:/ /efsmnt
  echo '${efs_dnsname}:/ /efsmnt efs _netdev,tls 0 0' >> /etc/fstab
  # Install Jenkins
  wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
  sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
  /usr/bin/apt-get update -y
  /usr/bin/apt-get install jenkins -y
  # Ensure we are running the latest WAR
  service jenkins stop
  mount -a
  chown jenkins:jenkins /efsmnt
  apt-get install --only-upgrade jenkins -y
  # Mount JENKINS_HOME -> EFS
  service jenkins stop
  sed -i '/JENKINS_HOME/c\JENKINS_HOME=/efsmnt' /etc/default/jenkins
  service jenkins start
  
fi

awk -F= '/^NAME/{print $2}' /etc/os-release | grep -i amazon
RESULTAMAZON=$?
if [ $RESULTAMAZON -eq 0 ]; then

  # Set hostname, ensure it remains   
  hostnamectl set-hostname ${appliedhostname}.${domain_name}
  echo $(hostname -I | cut -d\  -f1) $(hostname) | sudo tee -a /etc/hosts
  # Install Java
  /bin/yum install -y java-1.8.0-openjdk.x86_64
  # Create EFS mount folder & mount
  # Wait to ensure DNS propagation of the EFS endpoint
  sleep 15
  /bin/yum -y install nfs-utils amazon-efs-utils
  mkdir /efsmnt
  #mount -t efs -o tls ${efs_dnsname}:/ /efsmnt
  echo '${efs_dnsname}:/ /efsmnt nfs defaults,_netdev 0 0' >> /etc/fstab
  # Install Jenkins
  /bin/curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
  /bin/rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
  #/bin/rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
  /bin/yum update -y && /bin/yum install jenkins -y
  /bin/systemctl stop jenkins
  mount -a
  /bin/chown jenkins:jenkins /efsmnt
  /bin/sed -i '/JENKINS_HOME/c\JENKINS_HOME=/efsmnt' /etc/sysconfig/jenkins
  /bin/systemctl start jenkins && /bin/systemctl enable jenkins


  # Install CrowdStrike Agent
  # -------------------
  echo "Installing CloudStrike Agent..."
  PACKAGE_PATH="${TMP_DIR}/${PACKAGE}"
  
  # Get installer
  echo "    * Getting installer ${PACKAGE}..."
  /usr/bin/aws s3 cp s3://dev-mipulse-devops/rackspace/installers/armor/${PACKAGE} $TMP_DIR/

  # Install, avoiding the scaleft repo if present
  echo "    * Installing..."
  if [[ $(yum repolist) == *ScaleFT* ]];
  then
      /bin/yum --disablerepo=scaleft localinstall -y "$PACKAGE_PATH"
  else
      /bin/yum localinstall -y "$PACKAGE_PATH"
  fi

  # Set CID on the sensor
  echo "    * Setting CID on the sensor..."
  /opt/CrowdStrike/falconctl -s -f --cid="${CROWD_STRIKE_4_CCID}"

  # Start CloudStrike Agent
  echo "    * Starting falcon-sensor..."
  /usr/bin/systemctl start falcon-sensor

  echo "    * Waiting 15s to register with CrowdStrike..."
  sleep 15
  echo "    * Agent info: $(/opt/CrowdStrike/falconctl -g --cid --aid)"
  echo "    * Kernel info: $(uname -r)"

  # Install Armor
  # -------------
  /usr/bin/curl -sSL https://agent.armor.com/latest/armor_agent.sh | bash /dev/stdin -r us-west -l ${ARMOR_LICENSE_KEY}
  /usr/bin/sed -i 's/get-tasks$/get-tasks >\/dev\/null 2>\&1/' /etc/cron.d/armor-job-SUPERVISOR_TASKS
  /opt/armor/armor tags create-locked-tags provider_instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  sleep 10
  /opt/armor/armor vuln install
  /opt/armor/armor logging install
  /opt/armor/armor trend install
  /opt/armor/armor av on
  /opt/armor/armor fim on auto-apply-recommendations=on
  /opt/armor/armor ips detect auto-apply-recommendations=on
  /opt/ds_agent/dsa_control -m
  sleep 20
  /opt/armor/armor trend recommendation-scan
  /opt/armor/armor trend ongoing-recommendation-scan on

fi
# ----------------
# Allow for additional commands
# ----------------
${supplementary_user_data}
