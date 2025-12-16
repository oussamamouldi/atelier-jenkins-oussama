pipeline {
    agent any

    

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-login'
        DOCKERHUB_USER        = 'taiebbsaies'
        IMAGE_NAME            = "${DOCKERHUB_USER}/atelier-jenkins"
        IMAGE_TAG             = "${BUILD_ID}"
        IMAGE_LATEST          = "${IMAGE_NAME}:latest"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Checking out main branch"
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                echo "Building JAR"
                sh '''
                    chmod +x mvnw
                    ./mvnw clean compile
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Running SonarQube analysis"
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        chmod +x mvnw
                        ./mvnw sonar:sonar
                    '''
                }
            }
        }

        stage('Package Application') {
            steps {
                echo "Packaging JAR"
                sh '''
                    chmod +x mvnw
                    ./mvnw clean package -DskipTests
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_LATEST} .
                """
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKERHUB_CREDENTIALS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_LATEST}
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Image pushed → ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "FAILURE: Check Jenkins console output"
        }
        always {
            cleanWs()
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_LATEST} || true"
        }
    }
}
