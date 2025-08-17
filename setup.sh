#!/bin/bash

# Angular Jenkins Demo Setup Script
# This script sets up the complete environment for the demo

set -e

echo "🚀 Starting Angular Jenkins Demo Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install npm"
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker"
        exit 1
    fi
    
    # Check Minikube
    if ! command -v minikube &> /dev/null; then
        print_error "Minikube is not installed. Please install Minikube"
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl"
        exit 1
    fi
    
    print_status "All prerequisites are satisfied!"
}

# Start Minikube
start_minikube() {
    print_status "Starting Minikube..."
    
    if minikube status | grep -q "Running"; then
        print_warning "Minikube is already running"
    else
        minikube start --cpus=2 --memory=4096 --driver=docker
    fi
    
    # Enable ingress addon
    print_status "Enabling ingress addon..."
    minikube addons enable ingress
    
    print_status "Minikube is ready!"
}

# Build and deploy Docker image
build_docker_image() {
    print_status "Building Docker image..."
    
    # Build the image
    docker build -t ng-jenkins-demo:latest .
    
    # Load image into Minikube
    print_status "Loading image into Minikube..."
    minikube image load ng-jenkins-demo:latest
    
    print_status "Docker image built and loaded successfully!"
}

# Deploy to Kubernetes
deploy_to_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Create namespace
    kubectl apply -f k8s/namespace.yaml
    
    # Deploy application
    kubectl apply -f k8s/deployment.yaml
    
    # Wait for deployment to be ready
    print_status "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/ng-jenkins-demo -n ng-jenkins-demo
    
    print_status "Application deployed successfully!"
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    
    # Show all resources
    kubectl get all -n ng-jenkins-demo
    
    echo ""
    print_status "Access Information:"
    
    # Get Minikube IP
    MINIKUBE_IP=$(minikube ip)
    echo "Minikube IP: $MINIKUBE_IP"
    echo "Application URL: http://$MINIKUBE_IP:30080"
    echo "Health Check: http://$MINIKUBE_IP:30080/health"
    
    echo ""
    print_status "Useful Commands:"
    echo "View logs: kubectl logs -n ng-jenkins-demo -l app=ng-jenkins-demo"
    echo "Port forward: kubectl port-forward -n ng-jenkins-demo svc/ng-jenkins-demo-service 8080:80"
    echo "Dashboard: minikube dashboard"
}

# Main execution
main() {
    echo "=========================================="
    echo "  Angular Jenkins Demo Setup Script"
    echo "=========================================="
    echo ""
    
    check_prerequisites
    start_minikube
    build_docker_image
    deploy_to_kubernetes
    show_status
    
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure Jenkins with the Jenkinsfile"
    echo "2. Set up GitHub webhook for automatic deployment"
    echo "3. Push changes to main branch to trigger pipeline"
    echo ""
    echo "For more information, see README.md"
}

# Run main function
main "$@"
