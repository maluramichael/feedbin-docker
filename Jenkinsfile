pipeline {
    agent { label 'SRV-DOCKER-DEV' }
    stages {
        stage('Init'){
            agent { label 'SRV-DOCKER-DEV' }
            steps {
                script {
                    properties([pipelineTriggers([cron('@daily'), [$class: 'PeriodicFolderTrigger', interval: '1d']]), [$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10']]])
                }
                deleteDir()
            }
        }
        stage('Checkout'){
            agent { label 'SRV-DOCKER-DEV' }
            steps {
                // GIT submodule recursive checkout
                checkout scm: [
                        $class: 'GitSCM',
                        branches: scm.branches,
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'SubmoduleOption',
                                      disableSubmodules: false,
                                      parentCredentials: false,
                                      recursiveSubmodules: true,
                                      reference: '',
                                      trackingSubmodules: false]],
                        submoduleCfg: [],
                        userRemoteConfigs: scm.userRemoteConfigs
                ]
            }
        }
        stage('Docker build') {
            agent { label 'SRV-DOCKER-DEV' }
            steps {
                echo 'Starting to build docker image'
                script {
                    app = docker.build("thomasilliet/feedbin:${env.BUILD_ID}")
                }
            }
        }
        stage('Docker push - Latest') {
            agent { label 'SRV-DOCKER-DEV' }
            steps {
                script {
                    commitId = sh(returnStdout: true, script: 'cd app ; git rev-parse HEAD')
                    docker.withRegistry('https://registry.hub.docker.com', 'ca19e01b-db1a-43a3-adc4-46dafe13fea2') {
                        app.push("latest")
                        app.push(commitId)
                    }
                }
            }
        }

        stage('Docker push - Weekly') {
            agent { label 'SRV-DOCKER-DEV' }
            when { expression { dayOfWeek() == '7' } }
            steps {
                script {
                    commitId = sh(returnStdout: true, script: 'cd app ; git rev-parse HEAD')
                    docker.withRegistry('https://registry.hub.docker.com', 'ca19e01b-db1a-43a3-adc4-46dafe13fea2') {
                        app.push("weekly")
                    }
                }
            }
        }

        stage('Docker push - Monthly') {
            agent { label 'SRV-DOCKER-DEV' }
            when { expression { dayOfMonth() == '1' } }
            steps {
                script {
                    commitId = sh(returnStdout: true, script: 'cd app ; git rev-parse HEAD')
                    docker.withRegistry('https://registry.hub.docker.com', 'ca19e01b-db1a-43a3-adc4-46dafe13fea2') {
                        app.push("monthly")
                    }
                }
            }
        }

    }
}

def dayOfWeek() {
    String u = sh(returnStdout: true, script: 'date +%u')
    return u.trim()
}

def dayOfMonth() {
    String d = sh(returnStdout: true, script: 'date +%d')
    return d.trim()
}