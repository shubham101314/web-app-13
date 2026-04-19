pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    environment {
        DOCKER_IMAGE = "shubham101314/cake-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
        EC2_USER = "ec2-user"
        EC2_HOST = "<EC2_PUBLIC_IP>"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/shubham101314/web-app-13.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                """
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    """
                }
            }
        }

        stage('Push Image') {
            steps {
                sh """
                docker push $DOCKER_IMAGE:$DOCKER_TAG
                """
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST "
                        set -e
                        docker pull $DOCKER_IMAGE:$DOCKER_TAG &&
                        docker stop frontend || true &&
                        docker rm frontend || true &&
                        docker run -d -p 5000:80 --name frontend $DOCKER_IMAGE:$DOCKER_TAG
                    "
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline executed successfully"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}
