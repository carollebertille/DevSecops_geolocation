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
    stage('Update dev-values ') {
      when{  
          expression {
            env.Environment == 'main' }
            }
            steps {
                script {
                    sh '''
rm -rf k8s-manifests || true
git clone git@github.com:carollebertille/k8s-manifests.git
cd k8s-manifests/geolocation
ls
pwd
cat << EOF > charts/phonebook-app/dev-values.yaml
image:
  repository: edennolan2021/geocation
  tag: ${BUILD_NUMBER}
EOF
git config --global user.name "carollebertille"
git config --global user.email "carollematchum@gmail.com"

git add -A 
git commit -m "change from jenkins CI"
git push 
                    '''
                }
            }
        }
stage('wait for argocd') {
            steps {
                script {
                    sh '''
                     sleep 300
                    '''
                }
            }
        }
}
