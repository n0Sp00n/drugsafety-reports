#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 7: Create Application Load Balancer ==="
echo "Using subnets: $SUBNET_1, $SUBNET_2"
echo "Using security group: $SECURITY_GROUP_ID"

# Check if ALB exists
EXISTING_ALB=$(aws elbv2 describe-load-balancers --names drug-safety-alb --query 'LoadBalancers[0].LoadBalancerArn' --output text --region $AWS_REGION 2>/dev/null)

if [ "$EXISTING_ALB" != "None" ] && [ ! -z "$EXISTING_ALB" ]; then
  echo "✅ Load balancer already exists"
  ALB_ARN="$EXISTING_ALB"
  ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN --query "LoadBalancers[0].DNSName" --output text --region $AWS_REGION)
else
  echo "Creating Application Load Balancer..."
  ALB_ARN=$(aws elbv2 create-load-balancer \
    --name drug-safety-alb \
    --subnets $SUBNET_1 $SUBNET_2 \
    --security-groups $SECURITY_GROUP_ID \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4 \
    --query "LoadBalancers[0].LoadBalancerArn" --output text --region $AWS_REGION)

  if [ "$ALB_ARN" != "None" ] && [ ! -z "$ALB_ARN" ]; then
    ALB_DNS=$(aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN --query "LoadBalancers[0].DNSName" --output text --region $AWS_REGION)
    echo "✅ Load balancer created successfully!"
  else
    echo "❌ Failed to create load balancer"
    exit 1
  fi
fi

echo "ALB ARN: $ALB_ARN"
echo "ALB DNS: $ALB_DNS"

# Save ALB variables
save_var "ALB_ARN" "$ALB_ARN"
save_var "ALB_DNS" "$ALB_DNS"
