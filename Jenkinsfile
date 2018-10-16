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
            when { expression { getJobCause() == 'timer' || getJobCause() == 'pushtomaster' } }
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
            when { expression { dayOfWeek() == '7' && getJobCause() == 'timer' } }
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
            when { expression { dayOfMonth() == '1' && getJobCause() == 'timer' } }
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

@NonCPS
def getJobCause() {
  def jobCause = ''
  def buildCauses = currentBuild.rawBuild.getCauses()
  for ( buildCause in buildCauses ) {
    if (buildCause != null) {
      def causeProperties = buildCause.getProperties()
      if (causeProperties =~ /Started by user/) {
        jobCause = 'user'
      }
      if (causeProperties =~ /Started by timer/) {
        jobCause = 'timer'
      }
        if (causeProperties =~ /Started by an SCM change/) {
        jobCause = 'scm'
      }
      if (causeProperties =~ /Started by upstream/) {
        jobCause = 'upstream'
      }
      if (causeProperties =~ /Push event to branch master/) {
        jobCause = 'pushtomaster'
      }
      if (causeProperties =~ /Push event to branch unstable/) {
        jobCause = 'pushtounstable'
      } else {
        echo "cause properties: ${causeProperties}"
      }
    } else {
    }
  }
  echo "jobCause: ${jobCause}"
  return jobCause
}
