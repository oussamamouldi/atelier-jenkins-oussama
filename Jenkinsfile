pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        DOCKERHUB_USER  = 'oussama7024'
        IMAGE_NAME      = "${DOCKERHUB_USER}/atelier-jenkins"
        IMAGE_TAG       = "${BUILD_ID}"
        IMAGE_LATEST    = "${IMAGE_NAME}:latest"
    }

    triggers {
        pollSCM('*/2 * * * *')
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Checkout source code"
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                echo "🔧 Building project"
                sh '''
                    chmod +x mvnw
                    ./mvnw clean package -DskipTests
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "🔍 SonarQube analysis"
                withSonarQubeEnv('sonar') {
                    sh '''
                        chmod +x mvnw
                        ./mvnw sonar:sonar
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo "🐳 Building Docker image"
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_LATEST} .
                """
            }
        }

        stage('Docker Login & Push') {
            steps {
                echo "📤 Pushing image to Docker Hub"
                withCredentials([
                    usernamePassword(
                        credentialsId: "${DOCKERHUB_CREDENTIALS}",
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh """
                        echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_LATEST}
                        docker logout
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build & Push completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
        always {
            cleanWs()
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_LATEST} || true"
        }
    }
}
