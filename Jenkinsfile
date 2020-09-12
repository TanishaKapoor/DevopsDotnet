
pipeline
{
    agent any

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    environment {
        Nuget_Url = 'https://api.nuget.org/v3/index.json'
        SonarQube_Project_Key = 'sqs:k-raj1815-master'
        SonarQube_Project_Name = 'sqs:project-raj1815-master'
        SonarQube_Version = '1.0.0'
        scannerHome = tool name: 'sonar_scanner_dotnet', type: 'hudson.plugins.sonar.MsBuildSQRunnerInstallation'
    }

    stages {
        stage('nuget restore') {
            steps {
                echo 'hello! I’m in master environment'
                bat'dotnet clean'
                bat "dotnet restore -s ${env.Nuget_Proxy}"
            }
        }

        stage('Start sonarqube analysis') {
            steps {
                withSonarQubeEnv('Test_Sonar') {
                        bat "dotnet ${scannerHome}/SonarScanner.MsBuild.dll begin /k:${env.SonarQube_Project_Name}   /n:${env.SonarQube_Project_Name} /v:${env.SonarQube_Version}"
                }
            }
        }

        stage('Code build') {
            steps {
                bat 'dotnet build -c release -o app/build --no-restore'
            }
        }

        stage('Stop sonarqube analysis') {
            steps {
                withSonarQubeEnv('Test_Sonar') {
                    bat "dotnet ${scannerHome}/SonarScanner.MsBuild.dll end"
                }
            }
        }

        stage('Docker Image') {
            steps {
                bat "docker build -t  i-raj1815-master ."        
            }
            
        }

        stage('Containers') {
            parallel {
                stage('PrecontainerCheck') {
                    steps {
                        script {
                            containerID = powershell(returnStdout: true, script:'docker ps -af name=^"c-raj1815-master" --format "{{.ID}}"')
                            if (containerID) {
                                bat "docker stop ${containerID}"
                                bat "docker rm -f ${containerID}"
                            }
                        }
                    }
                }
                stage('PushtoDTR') {
                    steps {
                         bat "docker tag i-raj1815-master dtr.nagarro.com:443/i-raj1815-master:${BUILD_NUMBER}"
                         bat "docker push dtr.nagarro.com:443/i-raj1815-master:${BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('Docker deployment') {
                steps {
                bat "docker run -d -p 6200:80 --name c-raj1815-master dtr.nagarro.com:443/i-raj1815-master:${BUILD_NUMBER}"
                }
        }

        
            stage('Helm chart Deployment') {
                steps {   
                    script {
                        namespace = powershell(returnStdout: true, script:'kubectl get ns ns-raj1815-master  -o=custom-columns=NAME:.metadata.name --ignore-not-found')
                        if(!namespace){
                             bat "kubectl create ns ns-raj1815-master"
                        }
                    }
                            bat "helm upgrade raj1815-master-chart ./helmchart --install -n ns-raj1815-master --set image.tag=${BUILD_NUMBER}"
                      }
                    
            }
    }
}
