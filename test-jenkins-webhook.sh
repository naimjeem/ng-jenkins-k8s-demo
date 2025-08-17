#!/bin/bash

# Test Jenkins Webhook Connectivity
# This script helps test if your Jenkins webhook endpoint is accessible

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Jenkins Webhook Test Script${NC}"
echo "=================================="
echo ""

# Get Jenkins URL from user
read -p "Enter your Jenkins URL (e.g., http://localhost:8080): " JENKINS_URL

if [ -z "$JENKINS_URL" ]; then
    echo -e "${RED}❌ Jenkins URL is required${NC}"
    exit 1
fi

# Remove trailing slash if present
JENKINS_URL=${JENKINS_URL%/}

echo ""
echo -e "${BLUE}Testing Jenkins webhook endpoint...${NC}"
echo ""

# Test 1: Check if Jenkins is accessible
echo -e "${YELLOW}1. Testing Jenkins accessibility...${NC}"
if curl -s -f "${JENKINS_URL}" > /dev/null; then
    echo -e "${GREEN}✅ Jenkins is accessible at ${JENKINS_URL}${NC}"
else
    echo -e "${RED}❌ Jenkins is not accessible at ${JENKINS_URL}${NC}"
    echo -e "${YELLOW}Make sure Jenkins is running and accessible${NC}"
    exit 1
fi

echo ""

# Test 2: Check webhook endpoint
echo -e "${YELLOW}2. Testing webhook endpoint...${NC}"
WEBHOOK_URL="${JENKINS_URL}/github-webhook/"

if curl -s -f "${WEBHOOK_URL}" > /dev/null; then
    echo -e "${GREEN}✅ Webhook endpoint is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Webhook endpoint might not be configured${NC}"
    echo -e "${YELLOW}This is normal if webhooks aren't set up yet${NC}"
fi

echo ""

# Test 3: Send test webhook payload
echo -e "${YELLOW}3. Sending test webhook payload...${NC}"

# Create test payload
TEST_PAYLOAD='{
  "ref": "refs/heads/main",
  "repository": {
    "name": "ng-jenkins-demo",
    "full_name": "naimjeem/ng-jenkins-k8s-demo"
  },
  "pusher": {
    "name": "test-user",
    "email": "test@example.com"
  }
}'

echo "Sending payload to: ${WEBHOOK_URL}"
echo "Payload: ${TEST_PAYLOAD}"

# Send webhook
RESPONSE=$(curl -s -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -H "X-GitHub-Event: push" \
    -H "X-GitHub-Delivery: test-delivery-id" \
    -d "$TEST_PAYLOAD" \
    "${WEBHOOK_URL}")

HTTP_CODE="${RESPONSE: -3}"
BODY="${RESPONSE%???}"

echo ""
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
    echo -e "${GREEN}✅ Webhook sent successfully (HTTP $HTTP_CODE)${NC}"
    echo -e "${GREEN}Response: $BODY${NC}"
else
    echo -e "${YELLOW}⚠️  Webhook sent with HTTP $HTTP_CODE${NC}"
    echo -e "${YELLOW}Response: $BODY${NC}"
fi

echo ""
echo -e "${BLUE}Test completed!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Check Jenkins dashboard for triggered builds"
echo "2. Verify webhook delivery in GitHub repository settings"
echo "3. Check Jenkins system logs for any errors"
echo ""
echo -e "${BLUE}If webhook fails:${NC}"
echo "1. Ensure Jenkins is accessible from GitHub"
echo "2. Check if GitHub webhook plugin is installed"
echo "3. Verify webhook URL in GitHub repository settings"
echo "4. Use ngrok for local Jenkins testing if needed"
