@Library('jenkins-shared-library')_
pipeline {
    agent any 
    options {
        buildDiscarder(logRotator(numToKeepStr:'2'))
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
            /*agent {
                docker {
                  image 'maven:3.8-eclipse-temurin-17'
                }
               }*/
            steps {
                sh 'mvn test '
            }
        }
        stage('SonarQube analysis') {
           when{  
            expression {
              params.Environment == 'main' }
              }
            /*agent {
                docker {
                  image 'sonarsource/sonar-scanner-cli:4.7.0'
                }
               }*/
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
            /*agent {
                docker {
                  image 'maven:3.8-eclipse-temurin-17'
                }
               }*/
            steps {
                sh 'mvn clean package '
            }
        }
     stage('Docker Login') {
            steps {
                // Example of using DOCKERHUB and DOCKERHUB_PSW in a command
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'DOCKERHUB_PSW', usernameVariable: 'DOCKERHUB')]) {
                        sh """
                            docker login -u \$DOCKERHUB -p \$DOCKERHUB_PSW
                           
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
                        docker build -t edennolan2021/geolocation:${BUILD_NUMBER} .
                    '''
                }
            }
        }
        stage('Scan Image with  SNYK') {
            agent any
            environment{
                SNYK_TOKEN = credentials('snyk_token')
            }
            steps {
                script{
                    sh '''
                    echo "Starting Image scan edennolan2021/geolocation:${BUILD_NUMBER} ..." 
                    echo There is Scan result : 
                    SCAN_RESULT=$(docker run --rm -e SNYK_TOKEN=$SNYK_TOKEN -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/app snyk/snyk:docker snyk test --docker edennolan2021/geolocation:${BUILD_NUMBER} --json ||  if [[ $? -gt "1" ]];then echo -e "Warning, you must see scan result \n" ;  false; elif [[ $? -eq "0" ]]; then   echo "PASS : Nothing to Do"; elif [[ $? -eq "1" ]]; then   echo "Warning, passing with something to do";  else false; fi)
                    echo "Scan ended"
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
