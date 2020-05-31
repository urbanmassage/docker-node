pipeline {
  environment {
    DOCKER_USER = credentials('dockerhub-user')
    DOCKER_PASS = credentials('dockerhub-pass')
  }

  agent {
    kubernetes {
      containerTemplate {
        name 'build'
        image 'urbanmassage/urban-build:node-int-testing12-latest'
        ttyEnabled true
        alwaysPullImage true
        privileged true
        command 'cat'
      }
    }
  }

  stages {
    stage ('Setup') {
      steps {
        // send build started notifications
        slackSend (color: '#CCCCCC', message: "STARTED: ${env.JOB_NAME} [${env.BUILD_NUMBER}] \n${env.RUN_DISPLAY_URL}")
      }
    }

    stage('Test & Build') {
      steps {
        container('build') {
          sh './test-build.sh'
        }
      }
    }

    stage('Push') {
      steps {
        container('build') {
          sh './push.sh'
        }
      }
    }
  }

  post {
    success {
      slackSend (color: '#00FF00', message: "SUCCESSFUL: ${env.JOB_NAME} [${env.BUILD_NUMBER}] \n${env.RUN_DISPLAY_URL}")
    }

    failure {
      slackSend (color: '#FF0000', message: "FAILED: ${env.JOB_NAME} [${env.BUILD_NUMBER}] \n${env.RUN_DISPLAY_URL}")
    }
  }
}