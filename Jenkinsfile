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
    stage('List nodes') {
      steps {
        container('kubectl') {
          sh 'kubectl get nodes'
        }
      }
    }
  }
}
