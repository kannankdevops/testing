pipeline {
  agent {
    label 'kubectl-agent'
  }
  stages {
    stage('Verify kubectl') {
      steps {
        container('kubectl') {
          sh 'kubectl version --client'
        }
      }
    }
  }
}
