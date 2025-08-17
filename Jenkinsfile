pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'ng-jenkins-demo'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG = '/var/jenkins_home/.kube/config'
        MINIKUBE_IP = '192.168.49.2' // Default Minikube IP, adjust if needed
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'npm ci'
                    } else {
                        bat 'npm ci'
                    }
                }
            }
        }
        
        stage('Lint') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'npm run lint'
                    } else {
                        bat 'npm run lint'
                    }
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'npm run test -- --watch=false --browsers=ChromeHeadless'
                    } else {
                        bat 'npm run test -- --watch=false --browsers=ChromeHeadless'
                    }
                }
            }
            post {
                always {
                    publishTestResults testResultsPattern: '**/test-results.xml'
                    publishCoverage adapters: [coberturaAdapter('**/coverage/cobertura-coverage.xml')]
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'npm run build'
                    } else {
                        bat 'npm run build'
                    }
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    if (isUnix()) {
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    } else {
                        bat "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        bat "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }
        
        stage('Deploy to Minikube') {
            steps {
                script {
                    // Update Kubernetes deployment
                    if (isUnix()) {
                        sh """
                            kubectl set image deployment/ng-jenkins-demo ng-jenkins-demo=${DOCKER_IMAGE}:${DOCKER_TAG} --record
                            kubectl rollout status deployment/ng-jenkins-demo
                        """
                    } else {
                        bat """
                            kubectl set image deployment/ng-jenkins-demo ng-jenkins-demo=${DOCKER_IMAGE}:${DOCKER_TAG} --record
                            kubectl rollout status deployment/ng-jenkins-demo
                        """
                    }
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    // Wait for deployment to be ready
                    if (isUnix()) {
                        sh 'sleep 30'
                        sh "curl -f http://${MINIKUBE_IP}:30080/health || exit 1"
                    } else {
                        bat 'timeout /t 30 /nobreak > nul'
                        bat "curl -f http://${MINIKUBE_IP}:30080/health || exit 1"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images
            script {
                if (isUnix()) {
                    sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
                } else {
                    bat "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
                }
            }
        }
        
        success {
            echo "Pipeline completed successfully! App deployed to Minikube at http://${MINIKUBE_IP}:30080"
        }
        
        failure {
            echo "Pipeline failed! Check logs for details."
        }
    }
}
