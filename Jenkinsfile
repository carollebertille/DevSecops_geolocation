@Library('jenkins-shared-library')_

pipeline {
    agent {
     label ("node1")
          }
    options {
        buildDiscarder(logRotator(numToKeepStr:'2'))
        disableConcurrentBuilds()
        timeout (time: 60, unit: 'MINUTES')
        timestamps()
      }
    parameters {
        choice(
            choices: ['DEV', 'SANDBOX', 'PROD'], 
            name: 'Environment'
          )
    }
    environment {
        DOCKERHUB_ID= "edennolan2021"
        IMAGE_NAME = "geolocation"
        DOCKERHUB_PASSWORD = credentials('dockerhub')
        DEV_VERSION="0.0.${BUILD_NUMBER}
        STAGE_VERSION="0.0.${BUILD_NUMBER}
        RC_VERSION="1.0.${BUILD_NUMBER}
    }
    stages {
        stage('Login Dockerhub') {
            steps {
                script {
                    sh '''
                        echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_ID --password-stdin
                      '''
                }
            }
        }
        stage('maven build') {
            when{  
            expression {
              params.Environment == 'DEV' }
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
              params.Environment == 'DEV' }
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
              params.Environment == 'DEV' }
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
              params.Environment == 'DEV' }
              }
            steps {
                script {
                    sh '''
                        docker build -t $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION .
                    '''
                }
            }
        }
        stage('Scan Image with  SNYK') {
            agent any
            when{  
            expression {
              params.Environment == 'DEV' }
              }
            environment{
                SNYK_TOKEN = credentials('snyk_token')
            }
            steps {
                script{
                    sh '''
                    echo "Starting Image scan $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION ..." 
                    echo There is Scan result : 
                    SCAN_RESULT=$(docker run --rm -e SNYK_TOKEN=$SNYK_TOKEN -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/app snyk/snyk:docker snyk test --docker $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION --json ||  if [ $? -gt "1" ];then echo -e "Warning, you must see scan result \n" ;  false; elif [ $? -eq "0" ]; then   echo "PASS : Nothing to Do"; elif [ $? -eq "1" ]; then   echo "Warning, passing with something to do";  else false; fi)
                    echo "Scan ended"
                    '''
                }
            }
        }
        stage('Package dev') {
           when{  
            expression {
              params.Environment == 'DEV' }
              }
            steps {
                script {
                    sh '''
                        docker push $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION
                      '''
                }
            }
        }
         stage('Package sandbox') {
           when{  
            expression {
              params.Environment == 'SANDBOX' }
              }
            steps {
                script {
                    sh '''
                        docker pull $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION
                        docker tag $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION $DOCKERHUB_ID/$IMAGE_NAME:$STAGE_VERSION
                        docker push $DOCKERHUB_ID/$IMAGE_NAME:$STAGE_VERSION
                      '''
                }
            }
        }
        stage('Package prod') {
           when{  
            expression {
              params.Environment == 'PROD' }
              }
            steps {
                script {
                    sh '''
                        docker pull $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION
                        docker tag $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION $DOCKERHUB_ID/$IMAGE_NAME:$RC_VERSION
                        docker push $DOCKERHUB_ID/$IMAGE_NAME:$RC_VERSION
                      '''
                }
            }
        }
        stage('Deploy DEV') {
            steps {
                git branch: 'main', url: 'git@github.com:carollebertille/deployment-geolocation.git'
                sh "git config --global user.email 'carolle.matchum@yahoo.com' && git config --global user.name 'carollebertille'"
                sh "git checkout main"
                sh "cd ./overlays/dev/geolocation && kustomize edit set image $DOCKERHUB_ID/$IMAGE_NAME:$DEV_VERSION"
                sh "git commit -am 'Publish new dev release' && git push origin main:main || echo 'no change'"
            }
        }
        stage('Deploy SANDBOX') {
            steps {
                sh "git checkout main"
                sh "cd ./overlays/sandbox/geolocation && kustomize edit set image $DOCKERHUB_ID/$IMAGE_NAME:$STAGE_VERSION"
                sh "git commit -am 'Publish new sandbox release' && git push origin main:main || echo 'no change'"
            }
        }
        stage('Deploy PROD') {
            steps {
                sh "git checkout main"
                sh "cd ./overlays/prod/geolocation && kustomize edit set image $DOCKERHUB_ID/$IMAGE_NAME:$RC_VERSION"
                sh "git commit -am 'Publish new sandbox release' && git push origin main:main || echo 'no change'"
            }
        }
        stage('Argocd') {
            steps {
                sh "Wait for argocd"
            }
        }
                    
        
 }
}
