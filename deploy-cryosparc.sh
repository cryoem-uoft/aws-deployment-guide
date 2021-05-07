#!/bin/bash

set -e

while [[ ""$#"" -gt 0 ]]; do
    case $1 in
        --region) AWS_REGION="$2"; shift ;;
        --cluster-name) STACK_NAME="$2"; shift ;;
        --az) COMPUTE_AZ="$2"; shift ;;
        --config-bucket) CONFIG_BUCKET_NAME="$2"; shift ;;
        --data-bucket) DATA_BUCKET_NAME="$2"; shift ;;
        --aws-key) AWS_KEY="$2"; shift ;;
        --cryosparc-license-id) CRYOSPARC_LICENSE_ID="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

VPC_STACK_NAME=${STACK_NAME}-VPC

# Deploy CloudFormation template to set up VPC and subnets
echo "Deploying CryoSPARC CloudFormation stack"

aws cloudformation deploy --region ${AWS_REGION} \
                          --template-file vpc-cryosparc.template \
                          --stack-name ${VPC_STACK_NAME} \
                          --parameter-override AvailabilityZone=${COMPUTE_AZ} CryoSPARCConfigBucket=${CONFIG_BUCKET_NAME}
aws cloudformation wait stack-create-complete --stack-name ${VPC_STACK_NAME} --region ${AWS_REGION}

# Get VPC and Subnet IDs
VPC_ID=$(aws cloudformation describe-stacks --region ${AWS_REGION} --stack-name ${VPC_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" --output text)
echo "VPC ID: ${VPC_ID}"
COMPUTE_SUBNET_ID=$(aws cloudformation describe-stacks --region ${AWS_REGION} --stack-name ${VPC_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='PrivateSubnetId'].OutputValue" --output text)
echo "Compute Subnet ID: ${COMPUTE_SUBNET_ID}"
MASTER_SUBNET_ID=$(aws cloudformation describe-stacks --region ${AWS_REGION} --stack-name ${VPC_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='PublicSubnetId'].OutputValue" --output text)
echo "Master Subnet ID: ${MASTER_SUBNET_ID}"

# Edit add VPC and Subnet IDs to ParallelCluster configuration
cp cryosparc-pcluster.config.template cryosparc-pcluster.config
sed -i "s|@AWS_REGION@|${AWS_REGION}|g" cryosparc-pcluster.config
sed -i "s|@AWS_KEY@|${AWS_KEY}|g" cryosparc-pcluster.config
sed -i "s|@VPC_ID@|${VPC_ID}|g" cryosparc-pcluster.config
sed -i "s|@COMPUTE_SUBNET_ID@|${COMPUTE_SUBNET_ID}|g" cryosparc-pcluster.config
sed -i "s|@MASTER_SUBNET_ID@|${MASTER_SUBNET_ID}|g" cryosparc-pcluster.config
sed -i "s|@S3_CONFIG_BUCKET@|${CONFIG_BUCKET_NAME}|g" cryosparc-pcluster.config
sed -i "s|@S3_DATA_BUCKET@|${DATA_BUCKET_NAME}|g" cryosparc-pcluster.config
sed -i "s|@CRYOSPARC_LICENSE_ID@|${CRYOSPARC_LICENSE_ID}|g" cryosparc-pcluster.config

# Create ParallelCluster
pcluster create --region ${AWS_REGION} -nr -c cryosparc-pcluster.config ${STACK_NAME}

CRYOSPARC_HEADNODE_IPADDR=$(aws ec2 describe-instances --region $AWS_REGION --filters Name=tag:ClusterName,Values=${STACK_NAME} Name=tag:Name,Values=Master --query 'Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp' --output text)
echo ""
echo ""
echo "CryoSPARC cluster configuration complete. You can login using the following command:"
echo "(Be sure to use the correct path the SSH key you provided)"
echo ""
echo "ssh -i /path/to/key/${AWS_KEY} ec2-user@${CRYOSPARC_HEADNODE_IPADDR}"
echo ""
echo ""
echo "Once logged in, you will need to create a new user with the command:"
echo ""
echo "cryosparcm createuser --email email_address --password password --username username   --firstname firstname --lastname lastname"
echo ""
echo ""
echo "Once your user is created, you need to set up an SSH tunnel to the CryoSPARC head node"
echo "that will be used to connect to the CryoSPARC web interface:"
echo ""
echo "ssh -i /path/to/key/${AWS_KEY} -N -f -L localhost:45000:localhost:45000 ec2-user@${CRYOSPARC_HEADNODE_IPADDR}"
echo ""
echo "You can then open a web browser to http://localhost:45000"
echo "and log into CryoSPARC."
echo ""
