#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 6: Setup Networking ==="

# Get default VPC
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text --region $AWS_REGION)
echo "VPC ID: $VPC_ID"

# Get subnets from different AZs
echo "Getting subnets from different AZs..."
SUBNET_1=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=available" \
  --query "Subnets | sort_by(@, &AvailabilityZone) | [0].SubnetId" --output text --region $AWS_REGION)

SUBNET_2=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=state,Values=available" \
  --query "Subnets | sort_by(@, &AvailabilityZone) | [1].SubnetId" --output text --region $AWS_REGION)

AZ_1=$(aws ec2 describe-subnets --subnet-ids $SUBNET_1 --query 'Subnets[0].AvailabilityZone' --output text --region $AWS_REGION)
AZ_2=$(aws ec2 describe-subnets --subnet-ids $SUBNET_2 --query 'Subnets[0].AvailabilityZone' --output text --region $AWS_REGION)

echo "Subnet 1: $SUBNET_1 ($AZ_1)"
echo "Subnet 2: $SUBNET_2 ($AZ_2)"

# Create or get security group
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=drug-safety-sg" --query "SecurityGroups[0].GroupId" --output text --region $AWS_REGION 2>/dev/null)

if [ "$SG_ID" = "None" ] || [ -z "$SG_ID" ]; then
  echo "Creating security group..."
  SG_ID=$(aws ec2 create-security-group --group-name drug-safety-sg --description "Security group for Drug Safety API" --vpc-id $VPC_ID --query "GroupId" --output text --region $AWS_REGION)

  # Allow traffic
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 8080 --cidr 0.0.0.0/0 --region $AWS_REGION
  aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $AWS_REGION

  echo "✅ Security group created: $SG_ID"
else
  echo "✅ Using existing security group: $SG_ID"
fi

# Save networking variables
save_var "VPC_ID" "$VPC_ID"
save_var "SUBNET_1" "$SUBNET_1"
save_var "SUBNET_2" "$SUBNET_2"
save_var "SECURITY_GROUP_ID" "$SG_ID"

echo "✅ Networking setup complete"
