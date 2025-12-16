pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        IMAGE_NAME = "oussama7024/atelier-jenkins"    // change si tu veux
        DOCKERHUB_USER        = 'oussama7024'
        IMAGE_NAME            = "${DOCKERHUB_USER}/atelier-jenkins"
        IMAGE_TAG             = "${BUILD_ID}"
        IMAGE_LATEST          = "${IMAGE_NAME}:latest"
    }

    triggers {
        pollSCM('*/2 * * * *')   // vérifie GitHub chaque 2 minutes
    }


        stage('Clean') {
    stages {
        stage('Checkout') {
            steps {
                echo "🧹 Cleaning workspace..."
                sh "rm -rf build target dist"
                echo "Checking out main branch"
                checkout scm
            }
        }

        stage('Build Project') {
        stage('Build with Maven') {
            steps {
                echo "🔧 Building project..."

                // Adaptation automatique selon le type de projet
                echo "Building JAR"
                sh '''
                    if [ -f "pom.xml" ]; then
                        mvn clean package -DskipTests
                    elif [ -f "package.json" ]; then
                        npm install
                        npm run build || true
                    else
                        echo "⚠️ No build system detected."
                    fi
                    chmod +x mvnw
                    ./mvnw clean package -DskipTests
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
                echo "🐳 Building Docker image..."
                sh "docker build -t ${IMAGE_NAME}:latest ."
                echo "Building Docker image ${IMAGE_NAME}:${IMAGE_TAG}"
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_LATEST} .
                """
            }
        }

        stage('Docker Login & Push') {
        stage('Docker Push') {
            steps {
                echo "📤 Pushing image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push ${IMAGE_NAME}:latest
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKERHUB_CREDENTIALS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_LATEST}
                        docker logout
                    """
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build & Push completed successfully!"
            echo "SUCCESS: Image pushed → ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo "❌ Pipeline failed!"
            echo "FAILURE: Something went wrong"
        }
        always {
            cleanWs()
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_LATEST} || true"
        }
    }
}
