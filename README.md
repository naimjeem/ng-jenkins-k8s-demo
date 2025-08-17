# Jenkins Demo with Minikube Deployment

This is a demo Angular application with a complete CI/CD pipeline setup using Jenkins and Kubernetes (Minikube) for local development and deployment.

## 🚀 Features

- **Angular 17** application with modern UI
- **Jenkins Pipeline** for automated CI/CD
- **Docker** containerization
- **Kubernetes** deployment on Minikube
- **Automatic deployment** on merge to main branch
- **Health checks** and monitoring
- **Multi-stage Docker build** for optimization

## 📋 Prerequisites

Before running this demo, ensure you have the following installed:

- [Node.js 18+](https://nodejs.org/)
- [Angular CLI](https://angular.io/cli)
- [Docker](https://www.docker.com/)
- [Minikube](https://minikube.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Jenkins](https://www.jenkins.io/) (running on localhost:8000)

## 🛠️ Setup Instructions

### 1. Start Minikube

```bash
# Start Minikube with enough resources
minikube start --cpus=2 --memory=4096 --driver=docker

# Enable ingress addon
minikube addons enable ingress

# Check status
minikube status
```

### 2. Configure kubectl

```bash
# Point kubectl to Minikube
minikube kubectl -- get pods

# Or set context
kubectl config use-context minikube
```

### 3. Deploy to Minikube

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy the application
kubectl apply -f k8s/deployment.yaml

# Check deployment status
kubectl get all -n ng-jenkins-demo
```

### 4. Access the Application

```bash
# Get Minikube IP
minikube ip

# Access via NodePort (default: 30080)
# http://<minikube-ip>:30080

# Or via port forwarding
kubectl port-forward -n ng-jenkins-demo svc/ng-jenkins-demo-service 8080:80
# Then access: http://localhost:8080
```

### 5. Jenkins Setup

1. **Install Required Plugins:**
   - Git
   - Pipeline
   - Docker Pipeline
   - Kubernetes CLI
   - Test Results Aggregator
   - Cobertura

2. **Configure Jenkins:**
   - Add Docker credentials
   - Configure kubectl in Jenkins
   - Set up webhook for GitHub repository

3. **Create Pipeline Job:**
   - Use Jenkinsfile from this repository
   - Configure GitHub webhook to trigger on push to main branch

## 🔄 CI/CD Pipeline

The Jenkins pipeline includes the following stages:

1. **Checkout** - Clone source code
2. **Install Dependencies** - npm install
3. **Lint** - Code quality checks
4. **Test** - Unit tests with coverage
5. **Build** - Angular production build
6. **Docker Build** - Container image creation
7. **Deploy to Minikube** - Kubernetes deployment
8. **Health Check** - Verify deployment success

## 🐳 Docker

The application uses a multi-stage Docker build:

- **Builder stage**: Node.js environment for building Angular app
- **Production stage**: Nginx server for serving static files

## ☸️ Kubernetes

- **Namespace**: `ng-jenkins-demo`
- **Deployment**: 2 replicas with health checks
- **Service**: NodePort type exposing port 30080
- **Ingress**: Nginx ingress for external access

## 📁 Project Structure

```
ng-jenkins-demo/
├── src/                    # Angular source code
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml      # Namespace configuration
│   └── deployment.yaml     # Deployment, Service, Ingress
├── Dockerfile              # Multi-stage Docker build
├── nginx.conf              # Nginx configuration
├── Jenkinsfile             # Jenkins pipeline
├── package.json            # Node.js dependencies
└── README.md               # This file
```

## 🚀 Development

### Local Development

```bash
# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build

# Run tests
npm test

# Lint code
npm run lint
```

### Docker Development

```bash
# Build image
docker build -t ng-jenkins-demo:dev .

# Run container
docker run -p 8080:80 ng-jenkins-demo:dev

# Access at http://localhost:8080
```

## 🔧 Configuration

### Environment Variables

- `NODE_ENV`: Environment (development/production)
- `APP_VERSION`: Application version

### Ports

- **Development**: 4200 (Angular dev server)
- **Production**: 80 (Docker container)
- **Kubernetes**: 30080 (NodePort)

## 📊 Monitoring

- **Health Check**: `/health` endpoint
- **Logs**: Check container logs with `kubectl logs`
- **Metrics**: Kubernetes dashboard with `minikube dashboard`

## 🐛 Troubleshooting

### Common Issues

1. **Minikube not starting:**
   ```bash
   minikube delete
   minikube start --driver=docker
   ```

2. **Docker build failing:**
   ```bash
   docker system prune -a
   docker build --no-cache .
   ```

3. **Kubernetes deployment failing:**
   ```bash
   kubectl describe pod -n ng-jenkins-demo
   kubectl logs -n ng-jenkins-demo <pod-name>
   ```

4. **Jenkins pipeline failing:**
   - Check Jenkins logs
   - Verify kubectl configuration
   - Ensure Docker daemon is running

### Debug Commands

```bash
# Check Minikube status
minikube status

# View all resources
kubectl get all -n ng-jenkins-demo

# Check pod details
kubectl describe pod -n ng-jenkins-demo

# View logs
kubectl logs -n ng-jenkins-demo <pod-name>

# Port forward for debugging
kubectl port-forward -n ng-jenkins-demo svc/ng-jenkins-demo-service 8080:80
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Push to your branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Angular team for the amazing framework
- Jenkins community for CI/CD tools
- Kubernetes community for container orchestration
- Minikube team for local Kubernetes development
# Test Jenkins webhook integration - Mon, Aug 18, 2025 12:42:57 AM
