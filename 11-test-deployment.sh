#!/bin/bash

# Load global environment
source ~/.aws-ecs-env

echo "=== Step 11: Test Deployment ==="
echo "API URL: http://$ALB_DNS"

# Wait for service to be stable
echo "Waiting for service to be stable (this may take 3-5 minutes)..."
aws ecs wait services-stable --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION

echo ""
echo "Testing API endpoints..."

# Test health check
echo "1. Health Check:"
curl -s "http://$ALB_DNS/actuator/health" | jq . 2>/dev/null || curl "http://$ALB_DNS/actuator/health"

echo ""
echo "2. List Reports (should be empty):"
curl -s -u admin:password123 "http://$ALB_DNS/api/reports" | jq . 2>/dev/null || curl -u admin:password123 "http://$ALB_DNS/api/reports"

echo ""
echo "3. Create Test Report:"
curl -s -X POST "http://$ALB_DNS/api/reports" \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic YWRtaW46cGFzc3dvcmQxMjM=" \
  -d '{
    "reporterName": "Dr. ECS Test",
    "productName": "AWS Container Medicine",
    "issueDescription": "Successfully deployed to AWS ECS with Fargate!"
  }' | jq . 2>/dev/null || echo "Created report"

echo ""
echo "🎉 Testing complete!"
echo ""
echo "Access your API:"
echo "  • API Base: http://$ALB_DNS"
echo "  • Swagger UI: http://$ALB_DNS/swagger-ui.html"
echo "  • Health: http://$ALB_DNS/actuator/health"
echo ""
echo "Authentication: admin / password123"
