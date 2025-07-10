pipeline {
  agent {
    kubernetes {
      defaultContainer 'kubectl'
      yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
"""
    }
  }
  stages {
    stage('Check kubectl') {
      steps {
        container('kubectl') {
          sh 'kubectl version --client'
        }
      }
    }
  }
}
