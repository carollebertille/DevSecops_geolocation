pipeline {
    agent any
   
  
    stages {
        stage('Checkout'){
            steps{
                git branch: 'main', url: 'https://github.com/carollebertille/geolocation-5.git'
            }
        }
        stage('Login dockerhub'){
            steps{
                script {
                    def dockerImage = 'geolocation10'
                    def credentialsId = 'geolocation'

                    // Docker login
                    withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                    }
            }
        }
     }
        stage('Code Build') {
            agent {
                docker { image 'maven:3.9.4-eclipse-temurin-17-alpine' }
            }
            steps {
                sh '''
                    mvn --version
                    mvn test
                    mvn clean package
                '''
            }
        }
        // Building Docker images
        stage('Building image') {
            steps{
                    sh "docker build -t $dockerImage ."
                    sh "docker tag $dockerImage edennolan2021/$dockerImage"
                
            }
        }
        // Uploading Docker images into Dockerhub
        stage('Pushing to Dockerhub') {
            steps{
                
                sh "docker push edennolan2021/$dockerImage"
            }
        }
}
