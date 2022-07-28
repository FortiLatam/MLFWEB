pipeline {
    agent any
    options {
        skipStagesAfterUnstable()
    }
    stages {
         stage('Clone repository') { 
            steps { 
                script{
                checkout scm
                }
            }
        }

        stage('Build') { 
            steps { 
                script{
                 app = docker.build("mlfweb")
                }
            }
        }
        stage('CWP Scan'){
            steps {
                 fortiCWPScanner imageName: 'mlfweb:latest', block: false
            }
        }/*
        stage('SAST'){
            steps {
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
                 sh 'docker run --rm --mount type=bind,source="$PWD",target=/scan registry.fortidevsec.forticloud.com/fdevsec_sast:latest'
            }
        }*/
        stage('Push') {
            steps {
                script{
                        docker.withRegistry('https://371571523880.dkr.ecr.us-east-1.amazonaws.com/mlfweb', 'ecr:us-east-1:aws-credentials') {
                    app.push("${env.BUILD_NUMBER}")
                    app.push("latest")
                    }
                }
            }
        }
        stage('Deploy'){
            steps {
                 sh 'kubectl apply -f deployment.yml'
                 /*sh 'kubectl set image deployments/mlfweb 371571523880.dkr.ecr.us-east-1.amazonaws.com/mlfweb:${BUILD_NUMBER}'*/
            }
        } 
/*        stage('DAST'){
            steps {
                 sh 'sleep 1m'
                 sh 'docker pull registry.fortidevsec.forticloud.com/fdevsec_dast:latest'
                 sh 'docker run --rm --mount type=bind,source="$PWD",target=/scan registry.fortidevsec.forticloud.com/fdevsec_dast:latest'                 
            }
        }*/
    }
}
