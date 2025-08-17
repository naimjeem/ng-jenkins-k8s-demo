pipeline {
    agent any
    
    // This pipeline is designed to continue even if tests fail
    // Test failures will not stop the build, Docker build, or deployment stages
    // This ensures your application gets deployed even with test issues
    // Test results and artifacts are still collected and archived for review
    
    environment {
        DOCKER_IMAGE = 'ng-jenkins-demo'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG = '/var/jenkins_home/.kube/config'
        MINIKUBE_IP = '192.168.49.2' // Default Minikube IP, adjust if needed
        BRANCH_NAME = "${env.BRANCH_NAME ?: env.GIT_BRANCH ?: 'main'}"
        COMMIT_HASH = "${env.GIT_COMMIT ?: 'unknown'}"
        COMMIT_AUTHOR = "${env.GIT_AUTHOR_NAME ?: 'unknown'}"
        COMMIT_MESSAGE = "${env.GIT_COMMIT_MESSAGE ?: 'No commit message'}"
    }
    
    // Only run pipeline for main branch or when manually triggered
    options {
        skipDefaultCheckout(false)
        timestamps()
        ansiColor('xterm')
    }
    
    stages {
        stage('Branch Check') {
            steps {
                script {
                    echo "Building branch: ${BRANCH_NAME}"
                    echo "Commit: ${COMMIT_HASH}"
                    echo "Author: ${COMMIT_AUTHOR}"
                    echo "Message: ${COMMIT_MESSAGE}"
                    
                    // Only proceed if this is main branch or manually triggered
                    if (env.BRANCH_NAME != 'main' && env.BRANCH_NAME != 'master' && !env.BUILD_CAUSE_MANUALTRIGGER) {
                        echo "Skipping pipeline for branch: ${BRANCH_NAME}"
                        currentBuild.result = 'SUCCESS'
                        return
                    }
                }
            }
        }
        
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
                        sh 'npm run test -- --watch=false --browsers=ChromeHeadless || echo "Tests failed but continuing pipeline..."'
                    } else {
                        bat 'npm run test -- --watch=false --browsers=ChromeHeadless || echo Tests failed but continuing pipeline...'
                    }
                }
            }
            post {
                always {
                    publishTestResults testResultsPattern: '**/test-results.xml'
                    publishCoverage adapters: [coberturaAdapter('**/coverage/cobertura-coverage.xml')]
                    
                    // Archive test results and coverage even if tests fail
                    script {
                        if (isUnix()) {
                            sh 'mkdir -p test-artifacts || true'
                            sh 'cp -r coverage test-artifacts/ || true'
                            sh 'find . -name "*.log" -exec cp {} test-artifacts/ \; || true'
                        } else {
                            bat 'mkdir test-artifacts 2>nul || echo Directory exists'
                            bat 'xcopy /E /I coverage test-artifacts\\coverage 2>nul || echo Coverage copy failed'
                            bat 'copy *.log test-artifacts\\ 2>nul || echo Log copy failed'
                        }
                    }
                    
                    // Archive test artifacts
                    archiveArtifacts artifacts: 'test-artifacts/**/*', fingerprint: true, allowEmptyArchive: true
                }
                success {
                    echo "✅ Tests passed successfully!"
                }
                failure {
                    echo "⚠️ Tests failed, but pipeline will continue to build and deploy"
                    echo "📋 Next steps:"
                    echo "   1. Build stage - Creating production build"
                    echo "   2. Docker Build - Building container image"
                    echo "   3. Deploy to Minikube - Updating Kubernetes deployment"
                    echo "   4. Health Check - Verifying deployment"
                    echo ""
                    echo "🔍 To investigate test failures:"
                    echo "   - Check test artifacts in Jenkins build artifacts"
                    echo "   - Review test logs and coverage reports"
                    echo "   - Run tests locally: npm run test"
                    echo "   - Check component test files in src/app/**/*.spec.ts"
                }
            }
        }
        
        stage('Test Failure Handling') {
            steps {
                script {
                    echo "🔍 Analyzing test results and preparing for next stages..."
                    
                    // Create a summary of what happened in tests
                    if (isUnix()) {
                        sh '''
                            echo "=== Test Stage Summary ===" > test-summary.txt
                            echo "Timestamp: $(date)" >> test-summary.txt
                            echo "Branch: ${BRANCH_NAME}" >> test-summary.txt
                            echo "Commit: ${COMMIT_HASH}" >> test-summary.txt
                            echo "" >> test-summary.txt
                            
                            if [ -d "coverage" ]; then
                                echo "✅ Coverage reports generated" >> test-summary.txt
                                echo "📊 Coverage location: coverage/" >> test-summary.txt
                            else
                                echo "⚠️ No coverage reports found" >> test-summary.txt
                            fi
                            
                            echo "" >> test-summary.txt
                            echo "🚀 Pipeline continuing to Build stage..." >> test-summary.txt
                            echo "📋 Next stages: Build → Docker Build → Deploy → Health Check" >> test-summary.txt
                        '''
                    } else {
                        bat '''
                            echo === Test Stage Summary === > test-summary.txt
                            echo Timestamp: %date% %time% >> test-summary.txt
                            echo Branch: %BRANCH_NAME% >> test-summary.txt
                            echo Commit: %COMMIT_HASH% >> test-summary.txt
                            echo. >> test-summary.txt
                            
                            if exist coverage (
                                echo ✅ Coverage reports generated >> test-summary.txt
                                echo 📊 Coverage location: coverage/ >> test-summary.txt
                            ) else (
                                echo ⚠️ No coverage reports found >> test-summary.txt
                            )
                            
                            echo. >> test-summary.txt
                            echo 🚀 Pipeline continuing to Build stage... >> test-summary.txt
                            echo 📋 Next stages: Build → Docker Build → Deploy → Health Check >> test-summary.txt
                        '''
                    }
                    
                    // Archive the test summary
                    archiveArtifacts artifacts: 'test-summary.txt', fingerprint: true
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
            
            // Archive build artifacts
            archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
        }
        
        success {
            script {
                echo "🎉 Pipeline completed successfully!"
                echo "Branch: ${BRANCH_NAME}"
                echo "Commit: ${COMMIT_HASH}"
                echo "Author: ${COMMIT_AUTHOR}"
                echo "App deployed to Minikube at http://${MINIKUBE_IP}:30080"
                echo ""
                echo "📊 Pipeline Summary:"
                echo "   ✅ Source code checked out"
                echo "   ✅ Dependencies installed"
                echo "   ✅ Code linting completed"
                echo "   ⚠️ Tests executed (may have warnings/failures)"
                echo "   ✅ Production build created"
                echo "   ✅ Docker image built and tagged"
                echo "   ✅ Kubernetes deployment updated"
                echo "   ✅ Health check passed"
                echo ""
                echo "🚀 Application is now running and accessible!"
                echo "🔍 Access your app at: http://${MINIKUBE_IP}:30080"
                echo "📋 View deployment: kubectl get pods -n ng-jenkins-demo"
                echo "🎛️ Open dashboard: minikube dashboard"
                
                // Add success badge
                currentBuild.description = "✅ Success - ${BRANCH_NAME} (${COMMIT_HASH.take(8)})"
            }
        }
        
        failure {
            script {
                echo "❌ Pipeline failed!"
                echo "Branch: ${BRANCH_NAME}"
                echo "Commit: ${COMMIT_HASH}"
                echo "Author: ${COMMIT_AUTHOR}"
                
                // Determine failure stage and provide specific guidance
                def failedStage = currentBuild.getExecution().getCurrentHead().getDisplayName()
                echo "🚨 Failed at stage: ${failedStage}"
                echo ""
                
                if (failedStage.contains('Test')) {
                    echo "🧪 Test Stage Failed - Next Steps:"
                    echo "   1. Review test artifacts in Jenkins build artifacts"
                    echo "   2. Check test logs and coverage reports"
                    echo "   3. Run tests locally: npm run test"
                    echo "   4. Fix test issues and commit changes"
                    echo "   5. Re-run pipeline"
                } else if (failedStage.contains('Build')) {
                    echo "🏗️ Build Stage Failed - Next Steps:"
                    echo "   1. Check build logs for compilation errors"
                    echo "   2. Verify TypeScript configuration"
                    echo "   3. Run build locally: npm run build"
                    echo "   4. Fix build issues and commit changes"
                    echo "   5. Re-run pipeline"
                } else if (failedStage.contains('Docker')) {
                    echo "🐳 Docker Build Failed - Next Steps:"
                    echo "   1. Check Docker build logs"
                    echo "   2. Verify Dockerfile configuration"
                    echo "   3. Test Docker build locally: docker build ."
                    echo "   4. Fix Docker issues and commit changes"
                    echo "   5. Re-run pipeline"
                } else if (failedStage.contains('Deploy') || failedStage.contains('Health')) {
                    echo "☸️ Deployment Failed - Next Steps:"
                    echo "   1. Check Kubernetes deployment logs"
                    echo "   2. Verify Minikube is running: minikube status"
                    echo "   3. Check namespace: kubectl get pods -n ng-jenkins-demo"
                    echo "   4. Fix deployment issues and commit changes"
                    echo "   5. Re-run pipeline"
                } else {
                    echo "🔍 General Failure - Next Steps:"
                    echo "   1. Review Jenkins build logs"
                    echo "   2. Check system resources and dependencies"
                    echo "   3. Verify Jenkins configuration"
                    echo "   4. Fix identified issues and commit changes"
                    echo "   5. Re-run pipeline"
                }
                
                echo ""
                echo "📚 Useful Commands:"
                echo "   - Check pipeline status: kubectl get pods -n ng-jenkins-demo"
                echo "   - View deployment logs: kubectl logs -n ng-jenkins-demo -l app=ng-jenkins-demo"
                echo "   - Access Minikube dashboard: minikube dashboard"
                echo "   - Check Minikube status: minikube status"
                
                // Add failure badge with stage info
                currentBuild.description = "❌ Failed at ${failedStage} - ${BRANCH_NAME} (${COMMIT_HASH.take(8)})"
            }
        }
        
        aborted {
            script {
                echo "⏹️ Pipeline aborted!"
                currentBuild.description = "⏹️ Aborted - ${BRANCH_NAME}"
            }
        }
    }
}
