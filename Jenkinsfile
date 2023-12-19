pipeline {
    agent any 
    options {
        buildDiscarder(logRotator(numToKeepStr:'20'))
        disableConcurrentBuilds()
        timeout (time: 60, unit: 'MINUTES')
        timestamps()
      }
    environment {
        DOCKERHUB = credentials('dockerhub') 
    }
    stages {
       stage('Setup parameters') {
            steps {
                script {
                    properties([
                        parameters([    
                        choice(
                            choices: ['dev','main'], 
                            name: 'Environment'   
                                ),
                      ])
                    ])
                }
            }
        }
       stage('Code test') {
             when{  
            expression {
              env.Environment == 'main' }
              }
            agent {
                docker {
                  image 'maven:3.9.5-ibmjava-8'
                }
               }
            steps {
                sh 'mvn test '
            }
        }
        stage('SonarQube analysis') {
           when{  
            expression {
              env.Environment == 'main' }
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
              env.Environment == 'main' }
              }
            agent {
                docker {
                  image 'maven:3.9.5-ibmjava-8'
                }
               }
            steps {
                sh 'clean package '
            }
        }
     stage('Docker Login') {
            steps {
                script {
                    // Log in to Docker Hub
                    sh '''
                        echo "${DOCKERHUB_PSW}" | docker login --username "${DOCKERHUB_USR}" --password-stdin
                    '''
                }
            }
        }

        stage('Build image') {
           when{  
            expression {
              env.Environment == 'main' }
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
              env.Environment == 'main' }
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
