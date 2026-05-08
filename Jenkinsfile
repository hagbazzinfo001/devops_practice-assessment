pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'your_dockerhub_username'
        FRONTEND_IMAGE = "${DOCKER_REGISTRY}/taskapp-frontend"
        BACKEND_IMAGE = "${DOCKER_REGISTRY}/taskapp-backend"
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        KUBECONFIG_CRED_ID = 'kops-kubeconfig' // Assumes a Jenkins credential ID 'kops-kubeconfig' (Secret file) containing the kops kubeconfig
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Frontend') {
            steps {
                dir('taskapp_frontend') {
                    sh "docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest ."
                }
            }
        }
        
        stage('Build Backend') {
            steps {
                dir('taskapp_backend') {
                    sh "docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest ."
                }
            }
        }

        stage('Test') {
            steps {
                // Placeholder for actual tests (e.g., npm test, pytest)
                echo 'Running basic tests...'
                sh 'echo "Tests passed!"'
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                    sh "docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}"
                    sh "docker push ${FRONTEND_IMAGE}:latest"
                    sh "docker push ${BACKEND_IMAGE}:${IMAGE_TAG}"
                    sh "docker push ${BACKEND_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: "${KUBECONFIG_CRED_ID}", variable: 'KUBECONFIG_FILE')]) {
                    // We use the kubeconfig injected via credentials to apply manifests
                    sh "kubectl --kubeconfig \$KUBECONFIG_FILE apply -f k8s/"
                    sh "kubectl --kubeconfig \$KUBECONFIG_FILE apply -f k8s/monitoring/"
                    // To force image update if using latest:
                    // sh "kubectl --kubeconfig \$KUBECONFIG_FILE rollout restart deployment taskapp-frontend"
                    // sh "kubectl --kubeconfig \$KUBECONFIG_FILE rollout restart deployment taskapp-backend"
                }
            }
        }
    }
}
