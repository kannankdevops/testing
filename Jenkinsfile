pipeline {
  agent {
    label 'kubectl-agent'
  }
  stages {
    stage('Run kubectl') {
      steps {
        container('kubectl') {
          sh 'kubectl get nodes'
        }
      }
    }
  }
}
