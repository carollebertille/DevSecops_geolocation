@Library('jenkins-shared-library')_

pipeline {
    agent any 
    tools {
        maven 'Maven' 
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
        DOCKERHUB_ID= "edennolan2021"
        IMAGE_NAME = "geolocation"
        DOCKERHUB_PASSWORD = credentials('dockerhub')
    }
    stages {
        stage('maven build') {
            when{  
            expression {
              params.Environment == 'dev' }
              }
            agent {
                docker{
                    image 'edennolan2021/maven:3.6-openjdk-11'
                }
            }
            steps {
                sh  'mvn test'
            }
        }
        stage('SonarQube analysis') {
           when{  
            expression {
              params.Environment == 'dev' }
              }
                agent {
                 docker {
                 image 'edennolan2021/sonar-scanner-cli:4.8'
                 }
             }
                environment {
                 CI = 'true'
                  scannerHome='/opt/sonar-scanner'
            }
             steps{
               withSonarQubeEnv('Sonar') {
                 sh "${scannerHome}/bin/sonar-scanner"
            }
          }
       }
        stage("Quality Gate") {
            steps {
                // Wait for the SonarQube quality gate
                waitForQualityGate abortPipeline: true
            }
        }
        stage('maven build') {
            when{  
            expression {
              params.Environment == 'dev' }
              }
            agent {
                docker{
                    image 'edennolan2021/maven:3.6-openjdk-11'
                }
            }
            steps {
                sh  'mvn clean install package'
            }
        }
        stage('Build image') {
           when{  
            expression {
              params.Environment == 'dev' }
              }
            steps {
                script {
                    sh '''
                        docker build -t $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER} .
                    '''
                }
            }
        }
        stage('Scan Image with  SNYK') {
            agent any
            when{  
            expression {
              params.Environment == 'dev' }
              }
            environment{
                SNYK_TOKEN = credentials('snyk_token')
            }
            steps {
                script{
                    sh '''
                    echo "Starting Image scan $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER} ..." 
                    echo There is Scan result : 
                    SCAN_RESULT=$(docker run --rm -e SNYK_TOKEN=$SNYK_TOKEN -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/app snyk/snyk:docker snyk test --docker $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER} --json ||  if [[ $? -gt "1" ]];then echo -e "Warning, you must see scan result \n" ;  false; elif [[ $? -eq "0" ]]; then   echo "PASS : Nothing to Do"; elif [[ $? -eq "1" ]]; then   echo "Warning, passing with something to do";  else false; fi)
                    echo "Scan ended"
                    '''
                }
            }
        }
        stage('Login and push image') {
           when{  
            expression {
              params.Environment == 'dev' }
              }
            steps {
                script {
                    sh '''
                        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_ID --password-stdin
                        docker push $DOCKERHUB_ID/$IMAGE_NAME:${BUILD_NUMBER}
                      '''
                }
            }
        }
 }
}
