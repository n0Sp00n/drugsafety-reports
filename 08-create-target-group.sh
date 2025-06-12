#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 8: Create Target Group ==="
echo "Using VPC: $VPC_ID"

# Check if target group exists
EXISTING_TG=$(aws elbv2 describe-target-groups --names drug-safety-tg --query 'TargetGroups[0].TargetGroupArn' --output text --region $AWS_REGION 2>/dev/null)

if [ "$EXISTING_TG" != "None" ] && [ ! -z "$EXISTING_TG" ]; then
  echo "✅ Target group already exists"
  TG_ARN="$EXISTING_TG"
else
  echo "Creating target group..."
  TG_ARN=$(aws elbv2 create-target-group \
    --name drug-safety-tg \
    --protocol HTTP \
    --port 8080 \
    --vpc-id $VPC_ID \
    --target-type ip \
    --health-check-path /actuator/health \
    --health-check-interval-seconds 30 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --health-check-timeout-seconds 5 \
    --query "TargetGroups[0].TargetGroupArn" --output text --region $AWS_REGION)

  if [ "$TG_ARN" != "None" ] && [ ! -z "$TG_ARN" ]; then
    echo "✅ Target group created successfully!"
  else
    echo "❌ Failed to create target group"
    exit 1
  fi
fi

echo "Target Group ARN: $TG_ARN"
save_var "TARGET_GROUP_ARN" "$TG_ARN"
