@echo off
REM Angular Jenkins Demo Setup Script for Windows
REM This script sets up the complete environment for the demo

echo ==========================================
echo   Angular Jenkins Demo Setup Script
echo ==========================================
echo.

echo 🚀 Starting Angular Jenkins Demo Setup...
echo.

REM Check if required tools are installed
echo [INFO] Checking prerequisites...

REM Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed. Please install Node.js 18+
    pause
    exit /b 1
)

REM Check npm
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed. Please install npm
    pause
    exit /b 1
)

REM Check Docker
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed. Please install Docker
    pause
    exit /b 1
)

REM Check Minikube
where minikube >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Minikube is not installed. Please install Minikube
    pause
    exit /b 1
)

REM Check kubectl
where kubectl >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] kubectl is not installed. Please install kubectl
    pause
    exit /b 1
)

echo [INFO] All prerequisites are satisfied!
echo.

REM Start Minikube
echo [INFO] Starting Minikube...
minikube status | findstr "Running" >nul
if %errorlevel% equ 0 (
    echo [WARNING] Minikube is already running
) else (
    minikube start --cpus=2 --memory=4096 --driver=docker
)

REM Enable ingress addon
echo [INFO] Enabling ingress addon...
minikube addons enable ingress

echo [INFO] Minikube is ready!
echo.

REM Build and deploy Docker image
echo [INFO] Building Docker image...
docker build -t ng-jenkins-demo:latest .

REM Load image into Minikube
echo [INFO] Loading image into Minikube...
minikube image load ng-jenkins-demo:latest

echo [INFO] Docker image built and loaded successfully!
echo.

REM Deploy to Kubernetes
echo [INFO] Deploying to Kubernetes...

REM Create namespace
kubectl apply -f k8s\namespace.yaml

REM Deploy application
kubectl apply -f k8s\deployment.yaml

REM Wait for deployment to be ready
echo [INFO] Waiting for deployment to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/ng-jenkins-demo -n ng-jenkins-demo

echo [INFO] Application deployed successfully!
echo.

REM Show deployment status
echo [INFO] Deployment Status:
echo.
kubectl get all -n ng-jenkins-demo

echo.
echo [INFO] Access Information:

REM Get Minikube IP
for /f "tokens=*" %%i in ('minikube ip') do set MINIKUBE_IP=%%i
echo Minikube IP: %MINIKUBE_IP%
echo Application URL: http://%MINIKUBE_IP%:30080
echo Health Check: http://%MINIKUBE_IP%:30080/health

echo.
echo [INFO] Useful Commands:
echo View logs: kubectl logs -n ng-jenkins-demo -l app=ng-jenkins-demo
echo Port forward: kubectl port-forward -n ng-jenkins-demo svc/ng-jenkins-demo-service 8080:80
echo Dashboard: minikube dashboard

echo.
echo 🎉 Setup completed successfully!
echo.
echo Next steps:
echo 1. Configure Jenkins with the Jenkinsfile
echo 2. Set up GitHub webhook for automatic deployment
echo 3. Push changes to main branch to trigger pipeline
echo.
echo For more information, see README.md

pause
