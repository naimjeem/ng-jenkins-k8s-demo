#!/bin/bash

# Test Webhook Script for Jenkins Pipeline
# This script helps verify that your webhook setup is working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
JENKINS_URL="${JENKINS_URL:-http://localhost:8000}"
GITHUB_REPO="${GITHUB_REPO:-your-username/ng-jenkins-demo}"
WEBHOOK_SECRET="${WEBHOOK_SECRET:-}"

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}  Jenkins Webhook Test Script${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo ""
}

# Test 1: Check Jenkins accessibility
test_jenkins_access() {
    print_status "Testing Jenkins accessibility..."
    
    if curl -s -f "${JENKINS_URL}" > /dev/null; then
        print_status "✅ Jenkins is accessible at ${JENKINS_URL}"
    else
        print_error "❌ Jenkins is not accessible at ${JENKINS_URL}"
        print_warning "Make sure Jenkins is running and accessible"
        return 1
    fi
}

# Test 2: Check GitHub webhook endpoint
test_webhook_endpoint() {
    print_status "Testing GitHub webhook endpoint..."
    
    WEBHOOK_URL="${JENKINS_URL}/github-webhook/"
    
    if curl -s -f "${WEBHOOK_URL}" > /dev/null; then
        print_status "✅ GitHub webhook endpoint is accessible"
    else
        print_warning "⚠️  GitHub webhook endpoint might not be configured"
        print_warning "This is normal if webhooks aren't set up yet"
    fi
}

# Test 3: Simulate webhook payload
test_webhook_payload() {
    print_status "Testing webhook payload simulation..."
    
    # Create a sample webhook payload
    WEBHOOK_PAYLOAD=$(cat <<EOF
{
  "ref": "refs/heads/main",
  "before": "1234567890abcdef1234567890abcdef12345678",
  "after": "0987654321fedcba0987654321fedcba09876543",
  "repository": {
    "id": 123456789,
    "name": "ng-jenkins-demo",
    "full_name": "${GITHUB_REPO}",
    "private": false,
    "html_url": "https://github.com/${GITHUB_REPO}",
    "clone_url": "https://github.com/${GITHUB_REPO}.git"
  },
  "pusher": {
    "name": "test-user",
    "email": "test@example.com"
  },
  "commits": [
    {
      "id": "0987654321fedcba0987654321fedcba09876543",
      "message": "Test commit for webhook",
      "timestamp": "2025-08-17T16:00:00Z",
      "author": {
        "name": "Test User",
        "email": "test@example.com"
      }
    }
  ]
}
EOF
)

    WEBHOOK_URL="${JENKINS_URL}/github-webhook/"
    
    print_status "Sending test webhook payload to ${WEBHOOK_URL}"
    
    if [ -n "$WEBHOOK_SECRET" ]; then
        # Calculate signature if secret is provided
        SIGNATURE=$(echo -n "$WEBHOOK_PAYLOAD" | openssl dgst -sha1 -hmac "$WEBHOOK_SECRET" | cut -d' ' -f2)
        HEADERS="-H \"X-Hub-Signature: sha1=$SIGNATURE\""
    else
        HEADERS=""
    fi
    
    RESPONSE=$(curl -s -w "%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -H "X-GitHub-Event: push" \
        -H "X-GitHub-Delivery: test-delivery-id" \
        $HEADERS \
        -d "$WEBHOOK_PAYLOAD" \
        "${WEBHOOK_URL}")
    
    HTTP_CODE="${RESPONSE: -3}"
    BODY="${RESPONSE%???}"
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
        print_status "✅ Webhook payload sent successfully (HTTP $HTTP_CODE)"
        print_status "Response: $BODY"
    else
        print_warning "⚠️  Webhook payload sent with HTTP $HTTP_CODE"
        print_status "Response: $BODY"
    fi
}

# Test 4: Check pipeline job status
check_pipeline_status() {
    print_status "Checking pipeline job status..."
    
    # This would require Jenkins API access
    print_warning "Pipeline status check requires Jenkins API configuration"
    print_warning "Check manually in Jenkins dashboard"
}

# Test 5: Verify Minikube deployment
verify_deployment() {
    print_status "Verifying Minikube deployment..."
    
    if command -v kubectl &> /dev/null; then
        if kubectl get pods -n ng-jenkins-demo &> /dev/null; then
            print_status "✅ Kubernetes namespace exists"
            
            PODS=$(kubectl get pods -n ng-jenkins-demo --no-headers | wc -l)
            RUNNING_PODS=$(kubectl get pods -n ng-jenkins-demo --no-headers | grep Running | wc -l)
            
            print_status "Pods: $RUNNING_PODS/$PODS running"
            
            if [ "$RUNNING_PODS" -gt 0 ]; then
                print_status "✅ Deployment is running"
                
                # Test health endpoint
                if kubectl port-forward -n ng-jenkins-demo svc/ng-jenkins-demo-service 8081:80 --address=127.0.0.1 &
                then
                    PF_PID=$!
                    sleep 5
                    
                    if curl -s -f http://localhost:8081/health > /dev/null; then
                        print_status "✅ Health endpoint is responding"
                    else
                        print_warning "⚠️  Health endpoint not responding"
                    fi
                    
                    kill $PF_PID 2>/dev/null || true
                fi
            else
                print_warning "⚠️  No running pods found"
            fi
        else
            print_warning "⚠️  Kubernetes namespace not found"
        fi
    else
        print_warning "⚠️  kubectl not found"
    fi
}

# Main execution
main() {
    print_header
    
    print_status "Testing Jenkins webhook configuration..."
    echo ""
    
    # Run tests
    test_jenkins_access
    echo ""
    
    test_webhook_endpoint
    echo ""
    
    test_webhook_payload
    echo ""
    
    check_pipeline_status
    echo ""
    
    verify_deployment
    echo ""
    
    print_status "Webhook test completed!"
    echo ""
    print_status "Next steps:"
    print_status "1. Check Jenkins dashboard for pipeline jobs"
    print_status "2. Verify webhook delivery in GitHub repository"
    print_status "3. Test with actual code push to main branch"
    echo ""
}

# Run main function
main "$@"
