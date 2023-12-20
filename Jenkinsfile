@Library('jenkins-shared-library')_
pipeline {
    agent any 
    tools {
        maven 'Maven' // Name of the Maven installation configured in Jenkins
    }
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
    }
    environment {
        DOCKERHUB = credentials('dockerhub') 
        IMAGE_NAME = "geolocation"
        DOCKERHUB_ID = "edennolan2021"
        DOCKERHUB_PASSWORD = credentials('dockerhub')
    }
    stages {
        /*stage('SonarQube analysis') {
           when{  
            expression {
              params.Environment == 'main' }
              }
               environment {
                  scannerHome = tool 'Sonar'
               }
             steps {
                   script {
                       withSonarQubeEnv('SonarCloud') {
                          sh "${scannerHome}/bin/sonar-scanner"
                       }
                   }
            }
        }

        stage("Quality Gate") {
            steps {
                // Wait for the SonarQube quality gate
                waitForQualityGate abortPipeline: true
            }
        }*/
        stage('Build image') {
           when{  
            expression {
              params.Environment == 'main' }
              }
            steps {
                script {
                    sh '''
                        docker build -t $DOCKERHUB_ID/IMAGE_NAME:${BUILD_NUMBER} .
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
                    echo "Starting Image scan $DOCKERHUB_ID/IMAGE_NAME:${BUILD_NUMBER} ..." 
                    echo There is Scan result : 
                    SCAN_RESULT=$(docker run --rm -e SNYK_TOKEN=$SNYK_TOKEN -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/app snyk/snyk:docker snyk test --docker $DOCKERHUB_ID/IMAGE_NAME:${BUILD_NUMBER} --json ||  if [[ $? -gt "1" ]];then echo -e "Warning, you must see scan result \n" ;  false; elif [[ $? -eq "0" ]]; then   echo "PASS : Nothing to Do"; elif [[ $? -eq "1" ]]; then   echo "Warning, passing with something to do";  else false; fi)
                    echo "Scan ended"
                    '''
                }
            }
        }
        stage('push image') {
           when{  
            expression {
              params.Environment == 'main' }
              }
            steps {
                script {
                    sh '''
                        docker push $DOCKERHUB_ID/IMAGE_NAME:${BUILD_NUMBER}
                      '''
                }
            }
        }

 }
}
