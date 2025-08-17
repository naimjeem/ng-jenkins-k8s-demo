pipeline {
    agent any

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
        // ansiColor removed from here!
    }

    stages {
        stage('Branch Check') {
            steps {
                ansiColor('xterm') {
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
        }

        stage('Checkout') {
            steps {
                ansiColor('xterm') {
                    checkout scm
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                ansiColor('xterm') {
                    script {
                        if (isUnix()) {
                            sh 'npm ci'
                        } else {
                            bat 'npm ci'
                        }
                    }
                }
            }
        }

        stage('Lint') {
            steps {
                ansiColor('xterm') {
                    script {
                        if (isUnix()) {
                            sh 'npm run lint'
                        } else {
                            bat 'npm run lint'
                        }
                    }
                }
            }
        }

        stage('Test') {
            steps {
                ansiColor('xterm') {
                    script {
                        if (isUnix()) {
                            sh 'npm run test -- --watch=false --browsers=ChromeHeadless'
                        } else {
                            bat 'npm run test -- --watch=false --browsers=ChromeHeadless'
                        }
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
                ansiColor('xterm') {
                    script {
                        if (isUnix()) {
                            sh 'npm run build'
                        } else {
                            bat 'npm run build'
                        }
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                ansiColor('xterm') {
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
        }

        stage('Deploy to Minikube') {
            steps {
                ansiColor('xterm') {
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
        }

        stage('Health Check') {
            steps {
                ansiColor('xterm') {
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
    }

    post {
        always {
            ansiColor('xterm') {
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
        }

        success {
            ansiColor('xterm') {
                script {
                    echo "🎉 Pipeline completed successfully!"
                    echo "Branch: ${BRANCH_NAME}"
                    echo "Commit: ${COMMIT_HASH}"
                    echo "Author: ${COMMIT_AUTHOR}"
                    echo "App deployed to Minikube at http://${MINIKUBE_IP}:30080"

                    // Add success badge
                    currentBuild.description = "✅ Success - ${BRANCH_NAME} (${COMMIT_HASH.take(8)})"
                }
            }
        }

        failure {
            ansiColor('xterm') {
                script {
                    echo "❌ Pipeline failed!"
                    echo "Branch: ${BRANCH_NAME}"
                    echo "Commit: ${COMMIT_HASH}"
                    echo "Author: ${COMMIT_AUTHOR}"

                    // Add failure badge
                    currentBuild.description = "❌ Failed - ${BRANCH_NAME} (${COMMIT_HASH.take(8)})"
                }
            }
        }

        aborted {
            ansiColor('xterm') {
                script {
                    echo "⏹️ Pipeline aborted!"
                    currentBuild.description = "⏹️ Aborted - ${BRANCH_NAME}"
                }
            }
        }
    }
}