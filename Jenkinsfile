pipeline {
    agent any 
    options {
        buildDiscarder(logRotator(numToKeepStr:'20'))
        disableConcurrentBuilds()
        timeout (time: 60, unit: 'MINUTES')
        timestamps()
      }
    parameters {
        choice(
            choices: ['dev', 'main'], 
            name: 'Environment'
        )
        string(
            defaultValue: 'defaultUsername',
            description: 'DockerHub Username',
            name: 'DOCKERHUB'
        )
        password(
            defaultValue: 'defaultPassword',
            description: 'DockerHub Password',
            name: 'DOCKERHUB_PSW'
        )
    }
    /*environment {
        #DOCKERHUB = credentials('dockerhub') 
    }*/
    stages {
       stage('Code test') {
             when{  
            expression {
              params.Environment == 'main' }
              }
            agent {
                docker {
                  image 'maven:3.9.6-amazoncorretto-8-debian-bookworm'
                }
               }
            steps {
                sh 'mvn test '
            }
        }
        stage('SonarQube analysis') {
           when{  
            expression {
              params.Environment == 'main' }
              }
            agent {
                docker {
                  image 'sonarsource/sonar-scanner-cli:4.7.0'
                }
               }
               environment {
        CI = 'true'
        //  scannerHome = tool 'Sonar'
        scannerHome='/opt/sonar-scanner'
    }
            steps{
                withSonarQubeEnv('Sonar') {
                    sh "${scannerHome}/bin/sonar-scanner"
                }
            }
        }
      stage('Generate artifact') {
           when{  
            expression {
              params.Environment == 'main' }
              }
            agent {
                docker {
                  image 'maven:3.9.6-amazoncorretto-8-debian-bookworm'
                }
               }
            steps {
                sh 'clean package '
            }
        }
     stage('Docker Login') {
            steps {
                // Example of using DOCKERHUB and DOCKERHUB_PSW in a command
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERHUB_PSW', usernameVariable: 'DOCKERHUB')]) {
                        sh """
                            docker login -u \$DOCKERHUB -p \$DOCKERHUB_PSW
                            mvn test
                        """
                    }
                }
            }
        }

        stage('Build image') {
           when{  
            expression {
              params.Environment == 'main' }
              }
            steps {
                script {
                    sh '''
                        docker build -t edennolan2021/geolocation :${BUILD_NUMBER} .
                    '''
                }
            }
        }
        stage('push auth ') {
           when{  
            expression {
              params.Environment == 'main' }
              }
            steps {
                script {
                    
                    sh '''
                        docker push edennolan2021/geolocation:${BUILD_NUMBER} 
                    '''
                }
            }
        }

 }
}
