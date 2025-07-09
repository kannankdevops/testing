pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/kannankdevops/<your-repo-name>.git', branch: 'main'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t myapp .'
      }
    }

    stage('Run Docker Container') {
      steps {
        sh 'docker run --rm myapp'
      }
    }
  }
}
