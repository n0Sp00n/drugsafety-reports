#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 3: Create CloudWatch Log Group ==="

# Check if log group exists
EXISTING_LOG_GROUP=$(aws logs describe-log-groups --log-group-name-prefix "/ecs/drug-safety-api" --query 'logGroups[0].logGroupName' --output text 2>/dev/null)

if [ "$EXISTING_LOG_GROUP" = "/ecs/drug-safety-api" ]; then
  echo "✅ Log group already exists: /ecs/drug-safety-api"
else
  echo "Creating log group..."
  aws logs create-log-group --log-group-name /ecs/drug-safety-api --region $AWS_REGION

  if [ $? -eq 0 ]; then
    echo "✅ Log group created: /ecs/drug-safety-api"
  else
    echo "❌ Failed to create log group"
    exit 1
  fi
fi

save_var "LOG_GROUP_NAME" "/ecs/drug-safety-api"
