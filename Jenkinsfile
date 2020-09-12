
pipeline
{
    agent any

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    environment {
        Nuget_Url = 'https://api.nuget.org/v3/index.json'
        SonarQube_Project_Key = 'sqs:k-tanishakapoor-master'
        SonarQube_Project_Name = 'sqs:project-tanishakapoor-master'
        SonarQube_Version = '1.0.0'
        scannerHome = tool name: 'sonar_scanner_dotnet', type: 'hudson.plugins.sonar.MsBuildSQRunnerInstallation'
    }

    stages {
        stage('nuget restore') {
            steps {
                echo 'hello! I’m in master environment'
                bat'dotnet clean'
                bat "dotnet restore"
            }
        }

        stage('Start sonarqube analysis') {
            steps {
                withSonarQubeEnv('Test_Sonar') {
                        bat "dotnet \"${scannerHome}/SonarScanner.MsBuild.dll\" begin /k:${env.SonarQube_Project_Name}   /n:${env.SonarQube_Project_Name} /v:${env.SonarQube_Version}"
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
                    bat "dotnet \"${scannerHome}/SonarScanner.MsBuild.dll\" end"
                }
            }
        }
        stage('Release artifact') {
            steps {
                bat 'dotnet publish -c release -o app/release --no-restore'
            }
        }
        stage('Docker Image') {
            steps {
                bat "docker build -t  i-tanishakapoor-master ."        
            }
            
        }
    //   stage('PushtoDTR') {
    //                 steps {
    //                     //  bat "docker tag i-tanishakapoor-master dtr.nagarro.com:443/i-tanishakapoor-master:${BUILD_NUMBER}"
    //                     //  bat "docker push dtr.nagarro.com:443/i-tanishakapoor-master:${BUILD_NUMBER}"
    //                 }
    //     }
        stage('Stop Running Container') {
                     steps {
                        script {
                            containerID = powershell(returnStdout: true, script:'docker ps -af name=^"c-tanishakapoor-master" --format "{{.ID}}"')
                            if (containerID) {
                                bat "docker stop ${containerID}"
                                bat "docker rm -f ${containerID}"
                            }
                        }
                    }
            }

        stage('Docker deployment') {
                steps {
                bat "docker run -d -p 6000:80 --name c-tanishakapoor-master i-tanishakapoor-master"
                }
        }

        
            stage('Helm chart Deployment') {
                steps {   
                    script {
                        namespace = powershell(returnStdout: true, script:'kubectl get ns ns-tanishakapoor-master  -o=custom-columns=NAME:.metadata.name --ignore-not-found')
                        if(!namespace){
                             bat "kubectl create ns ns-tanishakapoor-master"
                        }
                    }
                            bat "helm upgrade tanishakapoor-master-chart ./helmchart --install -n ns-tanishakapoor-master --set image.tag=${BUILD_NUMBER}"
                      }
                    
            }
    }
}
