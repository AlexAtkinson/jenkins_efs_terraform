#!/usr/bin/env bash
# --------------------------------------------------------------------------------------------------
# launch-tf.sh
#
# Description: A quick script to facilitate launching this terraform module.
# Usage:
#     ./launch-tf.sh [ init | plan | apply | destory ]
#
# Notes:
#     - Currently supports only deploying into the Dev environment. Easily extensible.
#
# --------------------------------------------------------------------------------------------------
# User Input & Variables
# --------------------------------------------------------------------------------------------------
[ $# -eq 0 ] && { echo "Usage: $0 [ init | plan | apply | destroy ]"; exit 1; }
[ $# -gt 1 ] && { echo "ERROR: Only one terraform command can be used at a time!"; exit 1; }
[[ ! $1 =~ ^(init|plan|apply|destroy)$ ]] && { echo "ERROR: Only terraform commands 'init, plan, apply, destroy' are accepted!"; exit 1; }

tfcmd=$1

echo ''

if [[ $tfcmd != "destroy" ]]; then
    read -r -p "Will this be a new stack? [y/N] " response
    case $response in
        [yY][eE][sS]|[yY])
            uniquer="$(openssl rand -base64 128 | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1 | tr '[:upper:]' '[:lower:]')"
            ;;
        *)
            read -p $'Enter the random string of the existing stack (eg: <env>_jenkins_<audience>_\e[01mSTRING\e[0m): ' uniquer
            ;;
    esac
else
    read -p $'Enter the random string of the existing stack (eg: <env>_jenkins_<audience>_\e[01mSTRING\e[0m): ' uniquer
fi

echo -e "\n\n\nWhich environment will this stack be deployed in?\n"
PS3='Enter your selection: '
options=(
  "dev"
)
select opt in ${options[@]}
do
    case $opt in
        dev)
            environment=dev
            break
            ;;
        qa)
            environment=qa
            break
            ;;
        uat)
            environment=uat
            break
            ;;
        stag)
            environment=stag
            break
            ;;
        prod)
            environment=prod
            break
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
    esac
done

# This allows for group specific jenkins stacks.
echo -e "\n\n\nWho is this stack for?\n"
PS3='Enter your selection: '
options=(
  "foo"
  "bar"
)
select opt in ${options[@]}
do
    case $opt in
        foo)
            audience=ops
            break
            ;;
        bar)
            audience=mmna
            break
            ;;
        *)
            echo "invalid option $REPLY"
            ;;
    esac
done

if [[ $tfcmd != "destroy" ]]; then
    echo -e "\n\n\nWhich instance type should be used?\n"
    PS3='Enter your selection: '
    options=(
    "t3a.small"
    "t3a.medium"
    "t3a.large"
    "m5a.large"
    "c5a.large"
    "t3a.xlarge"
    "m5a.xlarge"
    "c5a.xlarge"
    )
    select opt in ${options[@]}
    do
        case $opt in
            t3a.small)
                instance_type=t3a.small
                break
                ;;
            t3a.medium)
                instance_type=t3a.medium
                break
                ;;
            t3a.large)
                instance_type=t3a.large
                break
                ;;
            m5a.large)
                instance_type=m5a.large
                break
                ;;
            c5a.large)
                instance_type=c5a.large
                break
                ;;
            t3a.xlarge)
                instance_type=t3a.xlarge
                break
                ;;
            m5a.xlarge)
                instance_type=m5a.xlarge
                break
                ;;
            c5a.xlarge)
                instance_type=c5a.xlarge
                break
                ;;
            *)
                echo "Invalid option $REPLY"
                ;;
        esac
    done
else
  instance_type="foo"
fi


if [[ $tfcmd != "destroy" ]]; then
    echo -e "\n\n"
    read -p "Enter the Armor License Key: " armor_license_key
else
    armor_license_key="foo"
fi

echo -e "\n\n"


stack_service=jenkins
stack_name="${environment}_${stack_service}_${audience}_${uniquer}"
domain_name="${stack_service}-${audience}-${uniquer}.UPDATE.THIS"


# --------------------------------------------------------------------------------------------------
# Main Operations
# --------------------------------------------------------------------------------------------------

# Workspace Handling
if terraform workspace list | grep $stack_name > /dev/null 2>&1; then
  terraform workspace select $stack_name
else
  terraform workspace new $stack_name
fi

# Launch Terraform
echo -e "\n\nINFO: Executing specified terraform command..."
terraform $tfcmd \
-var="aws_region=eu-west-1" \
-var="certificate_arn=" \
-var="contact=" \
-var="key_name=" \
-var="orchestration=" \
-var='private_subnet_ids=["subnet-","subnet-"]' \
-var='security_group_alb=["sg-"]' \
-var='private_subnet_cidr_blocks=["192.168.0.0/24","192.168.1.0/24"]' \
-var='public_subnet_ids=["subnet-","subnet-"]' \
-var='trusted_security_groups=["sg-"]' \
-var="vpc_id=vpc-" \
-var="zone_id=" \
-var="uniquer=${uniquer}" \
-var="environment=${environment}" \
-var="stack_name=${stack_name}" \
-var="domain_name=${domain_name}" \
-var="instance_type=${instance_type}" \
-var="armor_license_key=${armor_license_key}"

# Workspace Handling
echo -e "\n\nINFO: Switcing back to default workspace"
terraform workspace select default

# Cleanup
if [ "$tfcmd" == "destroy" ]; then
  echo -e "\n\n"
  read -r -p "If the stack deleted successfully, would you like to delete the terraform workspace $stack_name? [y/N] " response
  case $response in
      [yY][eE][sS]|[yY])
          echo -e "INFO: Deleting local terraform workspace..."
          terraform workspace delete $stack_name
          echo -e "INFO: Deleting s3 remote workspace..."
          aws s3 rm --recursive s3://BUCKET_NAME/env:/${stack_name}
          ;;
      *)
          echo -e "\e[01;33mWARN\e[0m: Terraform workspace $stack_name not deleted."
          ;;
  esac
fi

echo -e "\n"