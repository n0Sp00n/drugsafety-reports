#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 9: Create ALB Listener ==="
echo "ALB ARN: $ALB_ARN"
echo "Target Group ARN: $TARGET_GROUP_ARN"

# Check if listener exists
EXISTING_LISTENER=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --query 'Listeners[?Port==`80`].ListenerArn' --output text --region $AWS_REGION 2>/dev/null)

if [ ! -z "$EXISTING_LISTENER" ] && [ "$EXISTING_LISTENER" != "None" ]; then
  echo "✅ Listener already exists: $EXISTING_LISTENER"
  LISTENER_ARN="$EXISTING_LISTENER"
else
  echo "Creating listener..."
  LISTENER_ARN=$(aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN \
    --query 'Listeners[0].ListenerArn' --output text --region $AWS_REGION)

  if [ "$LISTENER_ARN" != "None" ] && [ ! -z "$LISTENER_ARN" ]; then
    echo "✅ Listener created successfully!"
  else
    echo "❌ Failed to create listener"
    exit 1
  fi
fi

echo "Listener ARN: $LISTENER_ARN"
save_var "LISTENER_ARN" "$LISTENER_ARN"
