pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-credentials'
        IMAGE_NAME = "oussama7024/atelier-jenkins"    // change si tu veux
    }

    triggers {
        pollSCM('*/2 * * * *')   // vérifie GitHub chaque 2 minutes
    }

    stages {

        stage('Checkout') {
            steps {
                echo "📥 Cloning repository..."
                git branch: 'main', url: 'https://github.com/oussamamouldi/atelier-jenkins-mx.git'
            }
        }

        stage('Clean') {
            steps {
                echo "🧹 Cleaning workspace..."
                sh "rm -rf build target dist"
            }
        }

        stage('Build Project') {
            steps {
                echo "🔧 Building project..."

                // Adaptation automatique selon le type de projet
                sh '''
                    if [ -f "pom.xml" ]; then
                        mvn clean package -DskipTests
                    elif [ -f "package.json" ]; then
                        npm install
                        npm run build || true
                    else
                        echo "⚠️ No build system detected."
                    fi
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo "🐳 Building Docker image..."
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                echo "📤 Pushing image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo "$PASS" | docker login -u "$USER" --password-stdin
                        docker push ${IMAGE_NAME}:latest
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
    }
}
